import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";
import type { ExtensionContext, ToolDefinition } from "@mariozechner/pi-coding-agent";
import { buildCodemodeApiPrompt } from "./builtins.js";
import { getExecutor } from "./executor-cache.js";
import { renderCodemodeCall, renderCodemodeResult } from "./render.js";
import { runCodemode } from "./runtime.js";
import { formatTraceForAgent, summarizeTraceForContext } from "./trace.js";
import type { CodemodeResultDetails } from "./types.js";
import { stripCodeFences } from "./util.js";

const codemodeSchema = Type.Object({
  code: Type.String({ description: "JavaScript code with tools.pi.* access" }),
});

export function createCodemodeTool(): ToolDefinition<typeof codemodeSchema, CodemodeResultDetails> {
  return {
    name: "codemode",
    label: "codemode",
    description: "Execute JavaScript in secure-exec with executor tools proxy",
    promptSnippet: buildCodemodeApiPrompt(),
    promptGuidelines: [
      "Write plain JavaScript body only. No imports/exports. No markdown fences.",
      "Use tools.pi.* only.",
      "Batch related work in one codemode call.",
    ],
    parameters: codemodeSchema,

    async execute(
      _toolCallId: string,
      params: { code: string },
      signal: AbortSignal | undefined,
      _onUpdate: unknown,
      ctx: ExtensionContext,
    ) {
      const code = stripCodeFences(params.code);
      const executor = await getExecutor(ctx.cwd);
      const result = await runCodemode({ code, cwd: ctx.cwd, executor, signal });

      return {
        content: [{ type: "text", text: formatTraceForAgent(result.trace, result.value, result.logs) }],
        details: {
          trace: result.trace,
          value: result.value,
          logs: result.logs,
          summary: summarizeTraceForContext(result.trace),
        },
      };
    },

    renderCall(args: { code?: string }, theme: any) {
      return renderCodemodeCall(args.code ?? "", theme);
    },

    renderResult(result, options, theme) {
      const trace = result.details?.trace;
      if (!trace) return new Text(theme.fg("error", "Missing codemode trace"), 0, 0);
      if (options.isPartial) return new Text(theme.fg("warning", "Executing..."), 0, 0);
      return renderCodemodeResult(trace, options.expanded, theme);
    },
  };
}
