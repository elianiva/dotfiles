/**
 * Loaded into subagent pi instances via -e flag.
 * Registers subagent_done + caller_ping tools.
 * Writes activity snapshots for parent-side status monitoring.
 * Auto-exits when agent completes (PI_SUBAGENT_AUTO_EXIT=1).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { writeFileSync } from "node:fs";
import { createRecorder } from "../subagent/activity.ts";

export default function (pi: ExtensionAPI) {
  const name = process.env.PI_SUBAGENT_NAME ?? "subagent";
  const sessionFile = process.env.PI_SUBAGENT_SESSION;
  const autoExit = process.env.PI_SUBAGENT_AUTO_EXIT === "1";

  const recorder = createRecorder({
    childId: process.env.PI_SUBAGENT_ID,
    activityFile: process.env.PI_SUBAGENT_ACTIVITY_FILE,
  });

  if (!sessionFile) return;

  // Write .exit sidecar — read by parent-side pollForDone as fast path.
  // Written explicitly by subagent_done / caller_ping tools.
  // NOT written by auto-exit (relies on pane sentinel instead).
  function done(type: "done" | "ping" | "error", extra: Record<string, unknown> = {}) {
    writeFileSync(`${sessionFile}.exit`, JSON.stringify({ type, name, ...extra }));
  }

  // ── Auto-exit (matching upstream pi-interactive-subagents) ──
  // On agent_end: if autoExit is set and the last assistant stopReason is not
  // "aborted", shut down immediately. User input does NOT prevent auto-exit —
  // upstream's shouldAutoExitOnAgentEnd intentionally ignores userTookOver.
  if (autoExit) {
    let agentStarted = false;

    pi.on("input", () => {
      if (!agentStarted) return;
    });

    pi.on("agent_start", () => {
      agentStarted = true;
    });

    pi.on("agent_end", (event, ctx) => {
      const messages = (event as any).messages as any[] | undefined;
      if (messages) {
        for (let i = messages.length - 1; i >= 0; i--) {
          const msg = messages[i];
          if (msg?.role === "assistant") {
            if (msg.stopReason === "aborted") return;
            break;
          }
        }
      }

      recorder.subagentDone();
      // Write sidecar + shutdown — sidecar lets parent detect completion
      // even if ctx.shutdown() doesn't exit the process cleanly.
      done("done");
      ctx.shutdown();
    });
  }

  // ── Activity lifecycle hooks ──

  pi.on("session_start", () => recorder.sessionStart());

  pi.on("agent_start", () => recorder.agentStart());

  pi.on("agent_end", () => recorder.agentEnd());

  pi.on("turn_start", () => recorder.turnStart());

  pi.on("turn_end", () => recorder.turnEnd());

  pi.on("tool_execution_start", (event) => {
    recorder.toolStart((event as any).toolName);
  });

  pi.on("tool_execution_end", () => recorder.toolEnd());

  pi.on("session_shutdown", () => recorder.sessionShutdown());

  // ── Tools ──

  pi.registerTool({
    name: "subagent_done",
    label: "Subagent Done",
    description:
      "Call when you have completed your task. Closes this session and returns your result to the parent. " +
      "Your LAST assistant message before calling this becomes the summary the parent sees.",
    parameters: Type.Object({}),
    async execute(_toolCallId, _params, _signal, _onUpdate, ctx) {
      recorder.subagentDone();
      done("done");
      ctx.shutdown();
      return { content: [{ type: "text", text: "Task completed. Shutting down." }], details: {} };
    },
  });

  pi.registerTool({
    name: "caller_ping",
    label: "Caller Ping",
    description:
      "Send a message to the parent agent and exit. Use when stuck, need clarification, " +
      "or need the parent to take action.",
    parameters: Type.Object({
      message: Type.String({ description: "What you need help with" }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      recorder.callerPing();
      done("ping", { message: params.message });
      ctx.shutdown();
      return { content: [{ type: "text", text: "Ping sent. Parent will be notified." }], details: {} };
    },
  });
}
