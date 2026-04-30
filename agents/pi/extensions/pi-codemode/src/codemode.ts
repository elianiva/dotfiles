import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";
import type { ExtensionContext, Theme, ToolDefinition } from "@mariozechner/pi-coding-agent";
import { buildCodemodeApiPrompt } from "./builtins.js";
import { getExecutor } from "./executor-cache.js";
import { renderCodemodeCall, renderCodemodeResult } from "./render.js";
import { runCodemode } from "./runtime.js";
import { formatTraceForAgent, summarizeTraceForContext } from "./trace.js";
import type { CodemodeResultDetails } from "./types.js";
import { buildPromptGuidelines, stripCodeFences } from "./util.js";

const codemodeSchema = Type.Object({
  code: Type.String({ description: "JavaScript code with tools.pi.* access" }),
});

export function createCodemodeTool(): ToolDefinition<typeof codemodeSchema, CodemodeResultDetails> {
  return {
    name: "codemode",
    label: "codemode",
    description: "Execute JavaScript in a secure sandbox with access to pi filesystem tools, fff search tools, and dynamically loaded executor tools (MCP, OpenAPI, GraphQL).",
    promptSnippet: buildCodemodeApiPrompt(),
    promptGuidelines: buildPromptGuidelines(),
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
      const result = await runCodemode({
        code,
        cwd: ctx.cwd,
        executor,
        signal,
      });
      const { text, images } = formatTraceForAgent(result.trace, result.value, result.logs);

      return {
        content: [
          { type: "text", text },
          ...images.map((img) => ({ type: "image" as const, data: img.data, mimeType: img.mimeType })),
        ],
        details: {
          trace: result.trace,
          value: result.value,
          logs: result.logs,
          summary: summarizeTraceForContext(result.trace),
        },
      };
    },

    renderCall(args: { code?: string }, theme: Theme) {
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
