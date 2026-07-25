/**
 * Protocol handler interface for the multi-protocol read tool.
 *
 * Each protocol module exports a handler that registers itself with the
 * read-tool router. Adding a new protocol means creating a module with
 * a handler — no need to edit the central router.
 */
import type { AgentToolResult, ExtensionContext } from "@earendil-works/pi-coding-agent";

export interface HandlerContext {
  cwd: string;
  signal?: AbortSignal;
  onUpdate?: (update: { content: Array<{ type: string; text: string }>; details?: unknown }) => void;
  rawCtx: ExtensionContext;
}

export interface ProtocolHandler {
  /** URI scheme (used for registration and error messages). */
  readonly scheme: string;
  /** Whether this handler can resolve the given path. */
  matches(path: string): boolean;
  /** Resolve the path and return tool result content. */
  resolve(
    path: string,
    ctx: HandlerContext,
    toolCallId: string,
    params: { offset?: number; limit?: number },
  ): Promise<AgentToolResult>;
}
