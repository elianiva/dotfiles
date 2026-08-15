/**
 * eval tool — omp-style persistent code cells in a sandboxed runtime.
 *
 * Two languages, one API surface:
 * - `lang: "js"` (default) — JavaScript inside a secure-exec VM. Cells run in
 *   order; `globalThis`, `var`, and `function` declarations persist across
 *   cells and across tool calls within the session (`let`/`const` are
 *   per-cell). The guest filesystem is the project cwd (read-write); network
 *   is denied; npm packages resolve from the project's node_modules.
 * - `lang: "python"` — Python inside a Monty sandbox (Rust interpreter,
 *   microsecond startup). Variables, functions and classes persist across
 *   cells; top-level await works. Emit output with print() — trailing
 *   expression values are captured but truncated, so don't return them.
 *   `/workspace` is the project cwd (read-write,
 *   open()/pathlib work). No network, no subprocesses, no third-party
 *   packages (stdlib subset: json, math, re, pathlib, os, sys, datetime,
 *   dataclasses, asyncio, typing, ...).
 *
 * Per-language state: each language keeps its own session; `reset: true`
 * wipes the state for the cell's language only.
 */

import { Type } from "typebox";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { EvalBridge } from "./bridge";
import { getJsSession, resetJsSession } from "./vm";
import { getPySession, resetPySession } from "./python/pool";
import type { EvalSession } from "./vm";
import type { PyEvalSession } from "./python/pool";
import type { CellRunResult } from "./types";

const DEFAULT_CELL_TIMEOUT_S = 30;
const MAX_CELL_TIMEOUT_S = 3600;
const MIN_CELL_TIMEOUT_S = 1;

const langSchema = Type.Optional(
  Type.Union([Type.Literal("js"), Type.Literal("python")], {
    description: 'Cell language (default "js"). Each language keeps its own persistent session state.',
  }),
);

const cellSchema = Type.Object({
  code: Type.String({ description: "Cell body. Top-level `await` and top-level `return` are supported (js). Python: print output with print() — trailing expression values are captured but truncated by an upstream Monty bug, so return values are not reliable." }),
  lang: langSchema,
  title: Type.Optional(Type.String({ description: "Short label rendered in the transcript (e.g. \"load config\")" })),
  timeout: Type.Optional(
    Type.Integer({
      minimum: MIN_CELL_TIMEOUT_S,
      maximum: MAX_CELL_TIMEOUT_S,
      description: `Per-cell timeout in seconds (default ${DEFAULT_CELL_TIMEOUT_S})`,
    }),
  ),
  reset: Type.Optional(
    Type.Boolean({ description: "Wipe the cell's language session state before running this cell" }),
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
    lang?: "js" | "python";
    title?: string;
    timeout?: number;
    reset?: boolean;
  }>;
};

export interface EvalCellResult {
  code: string;
  lang: "js" | "python";
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
    const header = `[${i + 1}/${cells.length}]${cell.title ? ` ${cell.title}` : ""}${cell.lang === "python" ? " python" : ""}`;
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

function toCellResult(input: { code: string; lang?: "js" | "python"; title?: string }, run: CellRunResult): EvalCellResult {
  const output = [run.stdout, run.stderr].filter(Boolean).join("");
  return {
    code: input.code,
    lang: input.lang ?? "js",
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
    description: `Execute JavaScript or Python code cells in a persistent, sandboxed runtime (omp-style eval).
Cells run in order; state persists within each language across cells and across tool calls within this session. Use reset: true to wipe the cell's language state.

Languages (per-cell \`lang\`):
- "js" (default) — secure-exec VM. globalThis/var/function declarations survive; let/const do not. Top-level await and top-level return are supported (the returned value is captured as structured output). npm packages from the project's node_modules are importable via await import(\`pkg\`).
- "python" — Monty sandbox (Rust Python 3.14 interpreter; microsecond startup). Variables, functions and classes persist; top-level await works. IMPORTANT: print instead of return — always emit results with print(); the trailing expression value is captured but truncated to {} for dicts by an upstream Monty bug, so never rely on it. /workspace is the project cwd (read-write) — use open()/pathlib. Stdlib subset only: json, math, re, pathlib, os, sys, datetime, dataclasses, asyncio, typing, collections-free (no itertools/collections in 0.0.19); no third-party packages.

Helpers inside cells:
- js: tool.<name>({...}) — exposed: \${EvalBridge.toolNames()}. Python: tool_<name>(...) with positional args or kwargs — bridge calls are async, so await them: await tool_read('/workspace/x.json'), tool_write('/workspace/out.txt', 'text'), tool_edit(path, edits), tool_grep(pattern, {'path': 'src'}), tool_find(pattern), tool_ls('/workspace'), tool_web_search('query').
- read(path, { offset?, limit? }) — js helper; python uses open()/pathlib on /workspace instead. Protocol URIs (https://, file://, skill://, pi://, issue://, pr://, conflict://, vault://) are delegated to the read tool.
- write(path, content) — js helper (protocol paths rejected).
- display(value) — emit structured JSON output into the transcript (both languages).
- env(name?) — read an allowlisted host env var (PWD, HOME, USER, SHELL, TERM, LANG, PATH); python also sees it via os.getenv/os.environ.

Sandbox rules (both languages): the guest filesystem is the project cwd (mounted read-write at /workspace); network access is denied; child processes stay inside the sandbox. Python: no third-party packages and no subprocess at all.

Per-cell timeout defaults to \${DEFAULT_CELL_TIMEOUT_S}s (1..\${MAX_CELL_TIMEOUT_S} allowed). On timeout the guest process is killed and the language's state is lost.

Do NOT shell out to node -e / bun -e / python -c via the bash tool for ad-hoc snippets — use this tool.`,
    promptSnippet: "Run JavaScript or Python code cells in a persistent sandboxed runtime (omp-style eval)",
    promptGuidelines: [
      "Use eval for ad-hoc code: parsing data, charting, testing snippets — not bash one-liners.",
      "Cells share state with the session per language; reset: true wipes the cell's language state. Prefer several small cells over one giant one.",
      "Python cells: print instead of return — always emit results with print(); trailing-expression/dict return values are truncated to {} by an upstream @pydantic/monty bug and are never captured reliably. No third-party packages; files live under /workspace.",
      "Sandboxed code can call tool.<name>() / tool_<name>() to use read/write/edit/grep/find/ls/web_search, but cannot reach the network directly.",
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

      // Language sessions boot lazily on first use of that language.
      let jsSession: EvalSession | undefined;
      let pySession: PyEvalSession | undefined;

      for (let i = 0; i < p.cells.length; i++) {
        const input = p.cells[i];
        const lang = input.lang ?? "js";
        const timeoutMs = clampTimeout(input.timeout);
        let session: { repl: { runCell(code: string, opts: { timeoutMs: number; signal?: AbortSignal; bridge: (name: string, args: unknown) => Promise<unknown> }): Promise<CellRunResult> } };
        try {
          if (lang === "python") {
            pySession ??= await getPySession(sessionId, ctx.cwd);
            session = pySession;
          } else {
            jsSession ??= await getJsSession(sessionId, ctx.cwd);
            session = jsSession;
          }
        } catch (e) {
          const message = e instanceof Error ? e.message : String(e);
          cells.push({ code: input.code, lang, title: input.title, status: "error", output: "", error: `eval unavailable: ${message}`, durationMs: 0, displays: [] });
          break;
        }
        if (input.reset) {
          try {
            if (lang === "python") await resetPySession(pySession!);
            else await resetJsSession(jsSession!);
          } catch (e) {
            const message = e instanceof Error ? e.message : String(e);
            cells.push({ code: input.code, lang, title: input.title, status: "error", output: "", error: `reset failed: ${message}`, durationMs: 0, displays: [] });
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
