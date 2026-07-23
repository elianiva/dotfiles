import { mkdirSync, writeFileSync, existsSync, readFileSync, unlinkSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import { Type, type Static } from "typebox";
import type { ExtensionAPI, ExtensionContext, ToolDefinition } from "@earendil-works/pi-coding-agent";
import {
  createTab,
  readOutputAsync,
  closePane,
  isHerdrAvailable,
  renamePane,
  runCommand,
} from "./herdr.ts";
import { loadAgent, resolveDenyTools, type AgentDefinition } from "./agent.ts";
import { getActivityFile, readActivityFile } from "./activity.ts";
import { advance, classify, createState, observe, type StatusState } from "./status.ts";
import { seedSessionFile, findLastAssistant, getNewEntries } from "./session.ts";
import { renderWidgetLines, type WidgetAgent } from "./widget.ts";

function formatDuration(ms: number): string {
  if (!Number.isFinite(ms) || ms <= 0) return "0ms";
  if (ms < 1_000) return `${ms}ms`;
  if (ms < 60_000) return `${(ms / 1000).toFixed(1)}s`;
  if (ms < 3_600_000) {
    const mins = Math.floor(ms / 60_000);
    const secs = Math.floor((ms % 60_000) / 1000);
    return secs > 0 ? `${mins}m${secs}s` : `${mins}m`;
  }
  if (ms < 86_400_000) {
    const hours = Math.floor(ms / 3_600_000);
    const mins = Math.floor((ms % 3_600_000) / 60_000);
    return mins > 0 ? `${hours}h${mins}m` : `${hours}h`;
  }
  const days = Math.floor(ms / 86_400_000);
  const hours = Math.floor((ms % 86_400_000) / 3_600_000);
  return hours > 0 ? `${days}d${hours}h` : `${days}d`;
}

// ── Module reload safety ──

const WIDGET_KEY = Symbol.for("pi-subagent/widget");
const STATUS_KEY = Symbol.for("pi-subagent/status");
const ABORT_KEY = Symbol.for("pi-subagent/abort");

function getAbortSignal(): AbortSignal {
  let ctrl = (globalThis as any)[ABORT_KEY] as AbortController | undefined;
  if (!ctrl) {
    ctrl = new AbortController();
    (globalThis as any)[ABORT_KEY] = ctrl;
  }
  return ctrl.signal;
}

// On reload: kill old state
{
  const p = (globalThis as any)[ABORT_KEY] as AbortController | undefined;
  if (p) p.abort();
  (globalThis as any)[ABORT_KEY] = new AbortController();
  const w = (globalThis as any)[WIDGET_KEY] as ReturnType<typeof setInterval> | undefined;
  if (w) clearInterval(w);
  (globalThis as any)[WIDGET_KEY] = null;
  const s = (globalThis as any)[STATUS_KEY] as ReturnType<typeof setInterval> | undefined;
  if (s) clearInterval(s);
  (globalThis as any)[STATUS_KEY] = null;
}

// ── Constants ──

const __dirname = dirname(fileURLToPath(import.meta.url));
const CHILD_EXT_PATH = join(__dirname, "..", "subagent-child", "index.ts");
const SENTINEL_RE = /__DELEGATE_DONE_(\d+)__/;

// ── Tool params ──

const SubagentTaskItem = Type.Object({
  agent: Type.Optional(Type.String({ description: "Agent type (scout, worker, reviewer). Default: worker" })),
  task: Type.String({ description: "Complete, self-contained instructions for the subagent" }),
  name: Type.Optional(Type.String({ description: "Tab label. Auto-generated if omitted" })),
  model: Type.Optional(Type.String({ description: "Model override" })),
  cwd: Type.Optional(Type.String({ description: "Working directory. Default: current project" })),
});

const SubagentParams = Type.Object({
  task: Type.Optional(Type.String({ description: "Task for a single subagent (fire-and-forget mode)" })),
  agent: Type.Optional(Type.String({ description: "Agent type for single mode (scout, worker, reviewer). Default: worker" })),
  name: Type.Optional(Type.String({ description: "Tab label for single mode. Auto-generated if omitted" })),
  model: Type.Optional(Type.String({ description: "Model override for single mode" })),
  cwd: Type.Optional(Type.String({ description: "Working directory for single mode. Default: current project" })),
  fork: Type.Optional(Type.Boolean({ description: "Inherit current conversation context (single mode only)" })),
  tasks: Type.Optional(Type.Array(SubagentTaskItem, { description: "Array of tasks to run in parallel (blocking mode — waits for all to complete)" })),
});
type SubagentParams = Static<typeof SubagentParams>;

// ── Result types ──

interface SubagentResult {
  name: string;
  agent: string;
  task: string;
  summary: string;
  sessionFile?: string;
  exitCode: number;
  elapsedMs: number;
  error?: string;
}

interface RunningSubagent {
  id: string;
  name: string;
  task: string;
  agent?: string;
  paneId: string;
  startTime: number;
  sessionFile: string;
  activityFile: string;
  statusState: StatusState;
  abortController: AbortController;
}

// ── Module state ──

let latestCtx: ExtensionContext | null = null;
const running = new Map<string, RunningSubagent>();

// ── Helpers ──

function shellQuote(s: string): string {
  return `'${s.replace(/'/g, "'\\''")}'`;
}

function getShellDelay(): number {
  const raw = process.env.PI_SUBAGENT_SHELL_READY_DELAY_MS?.trim();
  const n = raw ? Number.parseInt(raw, 10) : Number.NaN;
  return Number.isFinite(n) && n >= 0 ? n : 500;
}

function getSessionDir(cwd: string): string {
  const agentDir = process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
  const safe = `--${cwd.replace(/^[/\\]/, "").replace(/[/\\:]/g, "-")}--`;
  return join(agentDir, "sessions", safe, "subagent");
}

function getArtifactDir(sessionDir: string, subagentId: string): string {
  return join(sessionDir, "artifacts", subagentId);
}

// ── Sidecar ──

function readSidecar(
  sessionFile: string,
): { type: "done" | "ping" | "error"; name?: string; message?: string; error?: string } | null {
  const path = `${sessionFile}.exit`;
  if (!existsSync(path)) return null;
  try {
    const data = JSON.parse(readFileSync(path, "utf8"));
    unlinkSync(path);
    return data;
  } catch {
    return null;
  }
}

function resultFromSidecar(
  sidecar: { type: string; name?: string; message?: string; error?: string },
  agentName: string,
  name: string,
  task: string,
  sessionFile: string | undefined,
  startTime: number,
): SubagentResult {
  const elapsedMs = Date.now() - startTime;
  if (sidecar.type === "error") {
    const summary = sessionFile ? findLastAssistant([...getNewEntries(sessionFile, 0)]) : null;
    return { name, agent: agentName, task, summary: summary ?? sidecar.error ?? "Unknown error", sessionFile, exitCode: 1, elapsedMs, error: sidecar.error };
  }
  const summary = sessionFile ? findLastAssistant([...getNewEntries(sessionFile, 0)]) : null;
  return { name, agent: agentName, task, summary: summary ?? "(no output)", sessionFile, exitCode: 0, elapsedMs };
}

// ── Polling ──

async function pollForDone(
  r: RunningSubagent,
  signal: AbortSignal,
): Promise<SubagentResult> {
  const { paneId, sessionFile, name, task, startTime, agent } = r;
  const agentName = agent ?? "worker";

  while (!signal.aborted) {
    // Fast: .exit sidecar
    const sidecar = readSidecar(sessionFile);
    if (sidecar) return resultFromSidecar(sidecar, agentName, name, task, sessionFile, startTime);

    // Slow: sentinel in pane output
    try {
      const output = await readOutputAsync(paneId, 5);
      const m = output.match(SENTINEL_RE);
      if (m) {
        await new Promise((r2) => setTimeout(r2, 300));
        const late = readSidecar(sessionFile);
        if (late) return resultFromSidecar(late, agentName, name, task, sessionFile, startTime);

        const summary = findLastAssistant([...getNewEntries(sessionFile, 0)]) ||
          output.replace(SENTINEL_RE, "").trim() ||
          "(no output)";
        return { name, agent: agentName, task, summary, sessionFile, exitCode: parseInt(m[1], 10), elapsedMs: Date.now() - startTime };
      }
    } catch {
      // pane gone — keep polling, sidecar might arrive
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  return { name, agent: agentName, task, summary: "Cancelled", sessionFile, exitCode: 1, elapsedMs: Date.now() - startTime, error: "cancelled" };
}

// ── Widget ──

function refreshWidget() {
  if (!latestCtx?.hasUI) return;

  if (running.size === 0) {
    latestCtx.ui.setWidget("subagent-status", undefined);
    return;
  }

  latestCtx.ui.setWidget(
    "subagent-status",
    (_tui: any, _theme: any) => ({
      invalidate() {},
      render(width: number) {
        const agents: WidgetAgent[] = Array.from(running.values()).map((r) => ({
          name: r.name,
          agent: r.agent,
          startTime: r.startTime,
          statusState: r.statusState,
        }));
        return renderWidgetLines(agents, width);
      },
    }),
    { placement: "aboveEditor" },
  );
}

function startWidget() {
  if ((globalThis as any)[WIDGET_KEY]) return;
  refreshWidget();
  const timer = setInterval(refreshWidget, 1000);
  (globalThis as any)[WIDGET_KEY] = timer;
}

function startStatusMonitor(pi: ExtensionAPI) {
  if ((globalThis as any)[STATUS_KEY]) return;

  const timer = setInterval(() => {
    if (running.size === 0) return;

    const now = Date.now();

    for (const r of running.values()) {
      const activity = readActivityFile(r.activityFile, r.id);
      r.statusState = observe(r.statusState, activity, now);
      r.statusState = advance(r.statusState, now).next;
    }

    refreshWidget();
  }, 2000);

  (globalThis as any)[STATUS_KEY] = timer;
}

// ── Launch ──

async function launchSubagent(
  params: { task: string; agent?: string; name?: string; model?: string; cwd?: string; fork?: boolean },
  agentDef: AgentDefinition | null,
  agentName: string,
  ctx: ExtensionContext,
): Promise<RunningSubagent> {
  const startTime = Date.now();
  const id = Math.random().toString(16).slice(2, 10);
  const name = params.name ?? `${agentName}-${Date.now().toString(36)}`;
  const cwd = params.cwd ?? ctx.cwd;
  const sessionDir = getSessionDir(cwd);
  mkdirSync(sessionDir, { recursive: true });

  const ts = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 23) + "Z";
  const uuid = [id, Math.random().toString(16).slice(2, 10), Math.random().toString(16).slice(2, 10), Math.random().toString(16).slice(2, 6)].join("-");
  const sessionFile = join(sessionDir, `${ts}_${uuid}.jsonl`);
  const artifactDir = getArtifactDir(sessionDir, id);
  mkdirSync(artifactDir, { recursive: true });
  const activityFile = getActivityFile(artifactDir, id);
  mkdirSync(dirname(activityFile), { recursive: true });

  // Fork mode: seed child session with parent context
  const useFork = params.fork ?? agentDef?.sessionMode === "fork";
  if (useFork) {
    const parentFile = ctx.sessionManager.getSessionFile();
    if (parentFile) {
      seedSessionFile({
        mode: "fork",
        parentSessionFile: parentFile,
        childSessionFile: sessionFile,
        childCwd: cwd,
      });
    }
  }

  // Build task file
  const taskFile = join(artifactDir, "task.md");
  const modeHint = agentDef?.autoExit !== false
    ? "Complete your task autonomously."
    : "Complete your task. When finished, call the subagent_done tool.";
  const summaryHint = agentDef?.autoExit !== false
    ? "Your FINAL assistant message should summarize what you accomplished."
    : "Your FINAL assistant message (before calling subagent_done) should summarize what you accomplished.";
  const completionInstr = `\n\n## Completion\n${modeHint}\n\n${summaryHint}\n\nWhen you finish your task, call \`subagent_done\` to return your result. If stuck, call \`caller_ping\`.`;
  const fullPrompt = agentDef
    ? `${agentDef.systemPrompt}\n\n---\n\n${params.task}${completionInstr}`
    : `${params.task}${completionInstr}`;
  writeFileSync(taskFile, fullPrompt, "utf8");

  // Create herdr tab
  const paneId = createTab(name, cwd);
  renamePane(paneId, `[${name}]`);

  // Build pi command
  const piArgs = ["pi", "--session", shellQuote(sessionFile), "-e", shellQuote(CHILD_EXT_PATH)];

  const effectiveModel = params.model ?? agentDef?.model;
  if (effectiveModel) piArgs.push("--model", shellQuote(effectiveModel));

  const effectiveTools = agentDef?.tools;
  if (effectiveTools) {
    const BUILTIN_TOOLS = new Set(["read", "bash", "edit", "write", "grep", "find", "ls", "glob"]);
    const builtins = effectiveTools.split(",").map((t) => t.trim()).filter((t) => BUILTIN_TOOLS.has(t));
    if (builtins.length > 0) {
      piArgs.push("--tools", shellQuote(builtins.join(",")));
    }
  }

  piArgs.push(`@${shellQuote(taskFile)}`);

  // Write launch script
  const scriptDir = join(artifactDir, "scripts");
  mkdirSync(scriptDir, { recursive: true });
  const scriptPath = join(scriptDir, `${id}.sh`);

  const denySet = resolveDenyTools(agentDef);
  const envParts: string[] = [
    `PI_SUBAGENT_NAME=${shellQuote(name)}`,
    `PI_SUBAGENT_AGENT=${shellQuote(agentName)}`,
    `PI_SUBAGENT_SESSION=${shellQuote(sessionFile)}`,
    `PI_SUBAGENT_ID=${shellQuote(id)}`,
    `PI_SUBAGENT_ACTIVITY_FILE=${shellQuote(activityFile)}`,
    `PI_SUBAGENT_AUTO_EXIT=${agentDef?.autoExit !== false ? "1" : "0"}`,
  ];
  if (denySet.size > 0) {
    envParts.push(`PI_DENY_TOOLS=${shellQuote([...denySet].join(","))}`);
  }

  const envPrefix = envParts.join(" ") + " ";
  const scriptLines = [
    "#!/bin/bash",
    `cd ${shellQuote(cwd)}`,
    `${envPrefix}${piArgs.join(" ")}`,
    `echo __DELEGATE_DONE_$?__`,
  ];
  writeFileSync(scriptPath, scriptLines.join("\n") + "\n", { mode: 0o755 });

  // Brief delay for shell startup
  await new Promise((resolve) => setTimeout(resolve, getShellDelay()));

  runCommand(paneId, `bash ${shellQuote(scriptPath)}`);

  const abortController = new AbortController();
  const runningSubagent: RunningSubagent = {
    id,
    name,
    task: params.task,
    agent: agentName,
    paneId,
    startTime,
    sessionFile,
    activityFile,
    statusState: createState(startTime),
    abortController,
  };

  running.set(id, runningSubagent);
  return runningSubagent;
}

// ── Watch (fire-and-forget mode: steer result back when done) ──

async function watchSubagent(
  r: RunningSubagent,
  signal: AbortSignal,
  pi: ExtensionAPI,
): Promise<void> {
  const result = await pollForDone(r, signal);
  closePane(r.paneId);
  running.delete(r.id);
  refreshWidget();

  const elapsed = formatDuration(result.elapsedMs);
  const ref = result.sessionFile ? `\n\nSession: \`${result.sessionFile}\`` : "";
  let text: string;
  if (result.error) {
    text = `Subagent "${result.name}" failed (${elapsed}).\n\n${result.error}${ref}`;
  } else {
    text = `Subagent "${result.name}" completed (${elapsed}).\n\n${result.summary}${ref}`;
  }

  pi.sendMessage(
    {
      customType: "subagent_result",
      content: text,
      display: true,
      details: result as any,
    },
    { triggerTurn: true, deliverAs: "steer" },
  );
}

// ── Wait (parallel mode: block until done) ──

async function runSingleAndWait(
  r: RunningSubagent,
  signal: AbortSignal,
): Promise<SubagentResult> {
  try {
    const result = await pollForDone(r, signal);
    return result;
  } finally {
    closePane(r.paneId);
    running.delete(r.id);
  }
}

// ── Tool definition ──

export function createSubagentTool(pi: ExtensionAPI): ToolDefinition<typeof SubagentParams> {
  // Respect PI_DENY_TOOLS (set by parent agent for spawning control)
  const deniedTools = new Set(
    (process.env.PI_DENY_TOOLS ?? "")
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean),
  );

  if (deniedTools.has("subagent")) {
    return {
      name: "subagent",
      label: "Subagent",
      description: "Spawn a subagent in a new herdr tab.",
      parameters: Type.Object({ task: Type.String() }),
      execute: async () => ({
        content: [{ type: "text", text: "subagent is disabled for this agent." }],
        details: { error: "denied" },
      }),
    } as any;
  }

  // Capture context for widget
  pi.on("session_start", (_event, ctx) => {
    latestCtx = ctx;
  });

  // Cleanup
  pi.on("session_shutdown", () => {
    const w = (globalThis as any)[WIDGET_KEY] as ReturnType<typeof setInterval> | undefined;
    if (w) clearInterval(w);
    (globalThis as any)[WIDGET_KEY] = null;
    const s = (globalThis as any)[STATUS_KEY] as ReturnType<typeof setInterval> | undefined;
    if (s) clearInterval(s);
    (globalThis as any)[STATUS_KEY] = null;
    // Abort all running subagents
    for (const r of running.values()) {
      r.abortController.abort();
    }
    running.clear();
  });

  return {
    name: "subagent",
    label: "Subagent",
    description:
      "Spawn a pi subagent in a new herdr tab. Use for delegation — fire off independent exploration or scouting tasks. " +
      "Two modes:\n" +
      "1. Single mode (task + agent) — fire-and-forget: returns immediately, result steered back when done. Do NOT poll.\n" +
      "2. Parallel mode (tasks array) — blocks until all complete, returns aggregated results.\n\n" +
      "When to use:\n" +
      "- Delegate codebase recon to a scout while you focus on implementation\n" +
      "- Fire multiple scouts in parallel (each exploring different areas) for faster research\n" +
      "- Delegate a code review to reviewer while continuing to code\n" +
      "- Split large tasks into parallel work streams with multiple workers\n\n" +
      "Multiple single-mode subagents can run concurrently — fire several at once. " +
      "For parallel exploration, prefer the tasks array (blocking) when you need all answers before proceeding.",
    parameters: SubagentParams,
    execute: async (_toolCallId, params, signal, _onUpdate, ctx) => {
      if (!isHerdrAvailable()) {
        return { content: [{ type: "text", text: "subagent requires herdr." }], details: {} };
      }

      const hasSingle = Boolean(params.task);
      const hasParallel = Boolean(params.tasks && params.tasks.length > 0);

      if (!hasSingle && !hasParallel) {
        return { content: [{ type: "text", text: "Provide either `task` (single mode) or `tasks` (parallel mode)." }], details: {} };
      }

      if (hasSingle && hasParallel) {
        return { content: [{ type: "text", text: "Provide `task` or `tasks`, not both." }], details: {} };
      }

      // ── Parallel mode (blocking) ──
      if (hasParallel) {
        const taskDefs = params.tasks!;
        if (taskDefs.length > 8) {
          return { content: [{ type: "text", text: "Max 8 parallel tasks." }], details: {} };
        }

        // Prevent self-spawning
        const currentAgent = process.env.PI_SUBAGENT_AGENT;
        for (const t of taskDefs) {
          if (t.agent && currentAgent && t.agent === currentAgent) {
            return {
              content: [{ type: "text", text: `You are the ${currentAgent} agent — do not start another ${currentAgent}. Complete the task directly.` }],
              details: { error: "self-spawn blocked" },
            };
          }
        }

        startWidget();
        startStatusMonitor(pi);

        // Launch all
        const runningList: RunningSubagent[] = [];
        for (const t of taskDefs) {
          const agentDef = t.agent ? loadAgent(t.agent) : loadAgent("worker");
          const agentName = agentDef?.name ?? "worker";
          const r = await launchSubagent(
            { ...t, fork: false },
            agentDef,
            agentName,
            ctx,
          );
          runningList.push(r);
        }

        // Wait for all
        const results = await Promise.all(
          runningList.map((r) => runSingleAndWait(r, signal)),
        );

        refreshWidget();

        // Aggregate results
        const successCount = results.filter((r) => r.exitCode === 0).length;
        const summary = results.map((r) => {
          const status = r.exitCode === 0 ? "✓" : "✗";
          const elapsed = formatDuration(r.elapsedMs);
          const excerpt = r.summary.length > 200 ? r.summary.slice(0, 200) + "…" : r.summary;
          return `### ${status} ${r.agent}/${r.name} (${elapsed})\n\n${excerpt}`;
        }).join("\n\n---\n\n");

        return {
          content: [{ type: "text", text: `Parallel: ${successCount}/${results.length} tasks completed\n\n${summary}` }],
          details: { results, mode: "parallel" },
        };
      }

      // ── Single mode (fire-and-forget) ──
      const task = params.task!.trim();
      if (!task) return { content: [{ type: "text", text: "Missing `task`." }], details: {} };

      // Prevent self-spawning
      const currentAgent = process.env.PI_SUBAGENT_AGENT;
      if (params.agent && currentAgent && params.agent === currentAgent) {
        return {
          content: [{ type: "text", text: `You are the ${currentAgent} agent — do not start another ${currentAgent}. Complete the task directly.` }],
          details: { error: "self-spawn blocked" },
        };
      }

      const agentDef = params.agent ? loadAgent(params.agent) : loadAgent("worker");
      const agentName = agentDef?.name ?? "worker";

      let r: RunningSubagent;
      try {
        r = await launchSubagent(
          { task, agent: params.agent, name: params.name, model: params.model, cwd: params.cwd, fork: params.fork },
          agentDef,
          agentName,
          ctx,
        );
      } catch (err) {
        return {
          content: [{ type: "text", text: `Launch failed: ${err instanceof Error ? err.message : String(err)}` }],
          details: { error: "launch failed" },
        };
      }

      // Start background monitors
      startWidget();
      startStatusMonitor(pi);

      // Background watch — result steers back when done
      watchSubagent(r, r.abortController.signal, pi);

      return {
        content: [{ type: "text", text: `Spawned \`${r.name}\` in a new herdr tab. Result will appear when done.` }],
        details: { id: r.id, name: r.name, paneId: r.paneId, sessionFile: r.sessionFile, mode: "single" },
      };
    },
  };
}
