import {
  createBashToolDefinition,
  createEditToolDefinition,
  createFindToolDefinition,
  createGrepToolDefinition,
  createLsToolDefinition,
  createPowerShellToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
} from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Buffered tool-call display.
 *
 * While the model is still streaming a tool call's arguments, the TUI
 * normally re-renders the call row token-by-token (you watch the path/command
 * type itself out). This extension buffers that: while args are incomplete you
 * only see the tool's name label; the full rendered call row appears once the
 * arguments are complete.
 *
 * How it works:
 * - pi picks a same-named extension tool definition over the built-in one when
 *   rendering tool executions (`toolDefinition.renderCall ?? builtin.renderCall`
 *   in tool-execution.js), while omitting renderResult keeps the built-in
 *   result renderer. Execution is delegated unchanged via the spread built-in
 *   definition, so behavior/prompt metadata stay identical.
 * - If renderCall throws, pi falls back to a static bold tool-name label —
 *   which we use as the "still buffering" placeholder.
 * - We track which toolCallIds are mid-stream ourselves instead of trusting
 *   the renderer's argsComplete flag, because session-restored components
 *   never get setArgsComplete() and would otherwise render as placeholders
 *   forever.
 */

/** Subset of pi's tool render context we depend on. */
interface ToolRenderContext {
  toolCallId?: string;
}

// Built-in tools to wrap. Add entries here if you want custom tools buffered too.
const TOOL_FACTORIES = [
  createReadToolDefinition,
  createBashToolDefinition,
  createPowerShellToolDefinition,
  createEditToolDefinition,
  createWriteToolDefinition,
  createGrepToolDefinition,
  createFindToolDefinition,
  createLsToolDefinition,
] as const;

export default function (pi: ExtensionAPI) {
  // toolCallIds whose arguments are still streaming
  const streaming = new Set<string>();

  pi.on("message_update", (event) => {
    const message = event.message;
    if (message.role !== "assistant") return;
    for (const content of message.content) {
      if (content.type === "toolCall") streaming.add(content.id);
    }
  });

  pi.on("message_end", (event) => {
    if (event.message.role !== "assistant") return;
    for (const content of event.message.content) {
      if (content.type === "toolCall") streaming.delete(content.id);
    }
  });

  pi.on("session_start", (_event, ctx) => {
    for (const factory of TOOL_FACTORIES) {
      const def = factory(ctx.cwd);
      pi.registerTool({
        ...def,
        renderCall(args: unknown, theme: unknown, renderCtx: ToolRenderContext) {
          if (streaming.has(renderCtx?.toolCallId ?? "")) {
            // Caught by tool-execution.js → static tool-name fallback label
            throw new Error("args-buffered");
          }
          return def.renderCall?.(args as never, theme as never, renderCtx as never);
        },
        // No renderResult override → built-in result rendering is inherited
      });
    }
  });
}
