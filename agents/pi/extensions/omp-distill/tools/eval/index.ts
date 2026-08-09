/**
 * eval tool — omp-style persistent JavaScript cells inside a secure-exec VM.
 *
 * Cells run in order; `globalThis`, `var`, and `function` declarations persist
 * across cells and across tool calls within the session (`let`/`const` are
 * per-cell). The guest filesystem is the project cwd (read-write); network is
 * denied; npm packages resolve from the project's node_modules.
 */

import { Type } from "typebox";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { EvalBridge } from "./bridge";
import { getEvalSession, resetEvalSession } from "./vm";
import type { CellRunResult } from "./repl";

const DEFAULT_CELL_TIMEOUT_S = 30;
const MAX_CELL_TIMEOUT_S = 3600;
const MIN_CELL_TIMEOUT_S = 1;

const cellSchema = Type.Object({
  code: Type.String({ description: "JavaScript cell body. Top-level `await` and `return` are supported." }),
  title: Type.Optional(Type.String({ description: "Short label rendered in the transcript (e.g. \"load config\")" })),
  timeout: Type.Optional(
    Type.Integer({
      minimum: MIN_CELL_TIMEOUT_S,
      maximum: MAX_CELL_TIMEOUT_S,
      description: `Per-cell timeout in seconds (default ${DEFAULT_CELL_TIMEOUT_S})`,
    }),
  ),
  reset: Type.Optional(
    Type.Boolean({ description: "Wipe the persistent VM state before running this cell (state persists across cells otherwise)" }),
  ),
});

const params = Type.Object({
  cells: Type.Array(cellSchema, {
    minItems: 1,
    description: "Cells executed in order. State persists within each language across cells and across tool calls.",
  }),
});

type Params = {
  cells: Array<{
    code: string;
    title?: string;
    timeout?: number;
    reset?: boolean;
  }>;
};

export interface EvalCellResult {
  code: string;
  title?: string;
  status: "ok" | "error" | "timeout";
  output: string;
  error?: string;
  durationMs: number;
  displays: unknown[];
}

function clampTimeout(timeout: number | undefined): number {
  const seconds = timeout ?? DEFAULT_CELL_TIMEOUT_S;
  return Math.min(MAX_CELL_TIMEOUT_S, Math.max(MIN_CELL_TIMEOUT_S, seconds)) * 1000;
}

function renderCells(cells: EvalCellResult[]): string {
  const parts: string[] = [];
  for (let i = 0; i < cells.length; i++) {
    const cell = cells[i];
    const header = `[${i + 1}/${cells.length}]${cell.title ? ` ${cell.title}` : ""}`;
    const body: string[] = [header];
    if (cell.output) body.push(cell.output.trimEnd());
    for (const d of cell.displays) {
      body.push(JSON.stringify(d, null, 2));
    }
    if (cell.error) body.push(`Error: ${cell.error}`);
    parts.push(body.join("\n"));
  }
  return parts.join("\n\n");
}

function toCellResult(input: { code: string; title?: string }, run: CellRunResult): EvalCellResult {
  const output = [run.stdout, run.stderr].filter(Boolean).join("");
  return {
    code: input.code,
    title: input.title,
    status: run.ok ? "ok" : run.timedOut ? "timeout" : "error",
    output,
    error: run.error,
    durationMs: run.durationMs,
    displays: run.displays,
  };
}

export function createEvalTool(pi: ExtensionAPI) {
  return {
    name: "eval",
    label: "Eval",
    executionMode: "sequential" as const,
    description: `Execute JavaScript code in a persistent, sandboxed runtime (secure-exec VM).
Cells run in order; state persists across cells and across tool calls within this session (globalThis, var, and function declarations survive; let/const do not). Use reset: true to wipe state. Top-level await and top-level return are supported (the returned value is captured as structured output).

Helpers available inside cells:
- tool.<name>({...}) — call an agent tool from inside the sandbox. Exposed: ${EvalBridge.toolNames()}. Resolves to the tool's text output, or { text, details } when it returns structured details. Tool calls count against the cell timeout.
- read(path, { offset?, limit? }) — read a file (relative to the project cwd). Protocol URIs (https://, file://, skill://, pi://, issue://, pr://, conflict://, vault://) are delegated to the read tool.
- write(path, content) — write a file under the project cwd (protocol paths rejected).
- display(value) — emit structured JSON output into the transcript.
- env(name?) — read an allowlisted host env var (PWD, HOME, USER, SHELL, TERM, LANG, PATH).

Sandbox rules: the guest filesystem is the project cwd (mounted read-write). Network access is denied (fetch fails). Child processes run inside the VM only. Project npm packages are importable via await import(\`pkg\`).

Per-cell timeout defaults to ${DEFAULT_CELL_TIMEOUT_S}s (1..${MAX_CELL_TIMEOUT_S} allowed). On timeout the VM is killed and state is lost.

Do NOT shell out to node -e / bun -e via the bash tool for ad-hoc JavaScript — use this tool.`,
    promptSnippet: "Run JavaScript code cells in a persistent sandboxed runtime (omp-style eval)",
    promptGuidelines: [
      "Use eval for ad-hoc JavaScript: parsing data, charting, testing snippets — not bash one-liners.",
      "Cells share state with the session; reset: true wipes it. Prefer several small cells over one giant one.",
      "Sandboxed code can call tool.<name>() to use read/write/edit/grep/find/ls/web_search, but cannot reach the network directly.",
    ],
    parameters: params,

    async execute(
      _callId: string,
      p: Params,
      signal: AbortSignal | undefined,
      onUpdate:
        | ((u: { content: Array<{ type: string; text: string }>; details?: Record<string, unknown> }) => void)
        | undefined,
      ctx: ExtensionContext,
    ) {
      const sessionId = ctx.sessionManager.getSessionId() ?? "default";
      const bridge = EvalBridge.for(pi, ctx.cwd);
      const cells: EvalCellResult[] = [];
      const jsonOutputs: unknown[] = [];

      let session;
      try {
        session = await getEvalSession(sessionId, ctx.cwd);
      } catch (e) {
        const message = e instanceof Error ? e.message : String(e);
        return {
          content: [{ type: "text" as const, text: `eval unavailable: ${message}` }],
          details: { cells: [], jsonOutputs: [], isError: true, error: message },
        };
      }

      for (let i = 0; i < p.cells.length; i++) {
        const input = p.cells[i];
        const timeoutMs = clampTimeout(input.timeout);
        if (input.reset) {
          try {
            await resetEvalSession(session);
          } catch (e) {
            const message = e instanceof Error ? e.message : String(e);
            cells.push({ code: input.code, title: input.title, status: "error", output: "", error: `reset failed: ${message}`, durationMs: 0, displays: [] });
            break;
          }
        }
        const cellSignal = signal
          ? AbortSignal.any([signal, AbortSignal.timeout(timeoutMs)])
          : AbortSignal.timeout(timeoutMs);
        const result = await session.repl.runCell(input.code, {
          timeoutMs,
          signal,
          bridge: (name, args) => bridge.call(ctx, name, args, cellSignal),
        });
        const cell = toCellResult(input, result);
        cells.push(cell);
        jsonOutputs.push(...cell.displays);
        const isError = !result.ok;
        onUpdate?.({
          content: [{ type: "text", text: renderCells(cells) }],
          details: { phase: "cell", index: i, total: p.cells.length, isError },
        });
        if (isError) {
          return {
            content: [{ type: "text" as const, text: renderCells(cells) }],
            details: { cells, jsonOutputs, isError: true },
          };
        }
      }

      return {
        content: [{ type: "text" as const, text: renderCells(cells) }],
        details: { cells, jsonOutputs, isError: false },
      };
    },
  };
}
