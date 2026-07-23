/**
 * Multi-protocol read tool.
 *
 * Dispatches to registered protocol handlers. Adding a new protocol means
 * creating a handler module — no need to edit this router.
 *
 * Supported protocols:
 *   - file://            — stripped and delegated to native read
 *   - http:// / https://  — fetch web pages (Readability extraction, UA rotation, caching, GitHub repos)
 *   - skill://<name>     — read skill SKILL.md or a file inside the skill dir
 *   - pi://              — read pi documentation (README, docs/, examples/)
 *   - issue://<n>        — read a GitHub issue
 *   - pr://<n>           — read a GitHub pull request
 *   - conflict://[<path>] — read conflict info for the current repo or a specific file
 *
 * Non-protocol paths fall through to pi's native read tool.
 */
import { stat } from "node:fs/promises";
import { resolve, isAbsolute } from "node:path";
import { createReadToolDefinition, createLsToolDefinition } from "@earendil-works/pi-coding-agent";
import type {
  AgentToolResult,
  ExtensionContext,
  ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

import { httpHandler } from "./protocol/http";
import { skillHandler } from "./protocol/skill";
import { piDocHandler } from "./protocol/pi-docs";
import { issueHandler, prHandler } from "./protocol/github";
import { conflictHandler } from "./protocol/conflict";
import type { ProtocolHandler, HandlerContext } from "./protocol/types";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Details = Record<string, any>;

const readSchema = Type.Object({
  path: Type.String({
    description:
      "Local path, URL (https://...), or internal URI (skill://, pi://, issue://, pr://, conflict://). URL selectors like :N-M and :raw are supported.",
  }),
  offset: Type.Optional(
    Type.Number({
      description: "Line number to start reading from (1-indexed). Not supported for protocol URLs.",
    }),
  ),
  limit: Type.Optional(
    Type.Number({
      description: "Maximum number of lines to read. Not supported for protocol URLs.",
    }),
  ),
});

type ReadInput = { path: string; offset?: number; limit?: number };

const TOOL_DESCRIPTION = `Read file or directory contents, URLs, and internal resources.

Use this INSTEAD of: cat, head, tail, less, more (for file reads), or ls (for directory listing). There is no separate \`ls\` tool — \`read\` covers both.

Supports:
- **Files** — local filesystem paths, images (jpg, png, gif, webp, bmp). Prefix with file:// for explicit file paths.
- **Directories** — lists directory contents when path points to a directory.
- **URLs** — HTTP/HTTPS web pages (converted to markdown via Readability extraction, with caching and user-agent rotation). Also handles GitHub repos and video content.
- **skill://<name>** — read a skill's SKILL.md file
- **pi://** — browse pi documentation (README, docs/, examples/)
- **issue://<number>** — read a GitHub issue
- **pr://<number>** — read a GitHub pull request
- **conflict://[path]** — read conflict info (list all or show specific file)

URL selectors: append :N, :N-M, :N+K, :raw (e.g. https://example.com:50-100, https://example.com:raw)
For files, output is truncated to 2000 lines or 50KB. Use offset/limit for large files.`;

/** Registered protocol handlers in priority order. */
const handlers: ProtocolHandler[] = [
  httpHandler,
  skillHandler,
  piDocHandler,
  issueHandler,
  prHandler,
  conflictHandler,
];

/** file:// handler — strips prefix and delegates to native read. */
const fileHandler: ProtocolHandler = {
  scheme: "file",
  matches: (path) => path.startsWith("file://"),
  async resolve(path, ctx, toolCallId, params) {
    const filePath = path.slice("file://".length);
    const native = createReadToolDefinition(ctx.cwd);
    return native.execute(
      toolCallId,
      { path: filePath, offset: params.offset, limit: params.limit },
      ctx.signal,
      ctx.onUpdate as any,
      ctx.rawCtx as any,
    );
  },
};

/**
 * Create the overridden read tool definition.
 * Tries each registered handler, then falls back to native read.
 */
export function createProtocolReadTool(): ToolDefinition<typeof readSchema, Details> {
  return {
    name: "read",
    label: "read",
    description: TOOL_DESCRIPTION,
    promptGuidelines: [
      "Use read for files, directories, URLs, skill://, pi://, issue://, pr://, and conflict:// resources",
      "Use read with a directory path to list contents instead of ls",
      "Use offset/limit for large files instead of head/tail",
      "For web pages, the tool returns markdown-converted content (Readability extraction with UA rotation)",
      "GitHub URLs are auto-detected and cloned/extracted via the read tool",
      "skill://<name> — read a skill's SKILL.md file",
      "pi://[path] — browse pi docs (README, docs/, examples/)",
      "issue://<N> (or issue://<owner>/<repo>/<N>) — read a GitHub issue (disk-cached)",
      "pr://<N> (or pr://<owner>/<repo>/<N>) — read a GitHub PR (disk-cached)",
      "conflict://[path] — read conflict info for the current repo or a specific file",
      "conflict:// without a path lists all conflicted files; conflict://<path> shows details",
    ],
    parameters: readSchema,

    async execute(
      toolCallId: string,
      params: ReadInput,
      signal: AbortSignal | undefined,
      onUpdate: any,
      ctx: ExtensionContext,
    ): Promise<AgentToolResult<Details>> {
      const rawPath = String(params.path);
      const handlerCtx: HandlerContext = { cwd: ctx.cwd, signal, onUpdate, rawCtx: ctx };

      // 1. Try registered protocol handlers (file:// goes through fileHandler)
      for (const handler of [fileHandler, ...handlers]) {
        if (handler.matches(rawPath)) {
          return handler.resolve(rawPath, handlerCtx, toolCallId, params);
        }
      }

      // 2. Check if path is a directory → delegate to ls for directory listing
      const resolvedPath = isAbsolute(rawPath) ? rawPath : resolve(ctx.cwd, rawPath);
      try {
        const s = await stat(resolvedPath);
        if (s.isDirectory()) {
          const ls = createLsToolDefinition(ctx.cwd);
          return ls.execute(
            toolCallId,
            { path: rawPath, limit: params.limit },
            signal,
            onUpdate as any,
            ctx as any,
          );
        }
      } catch {
        // not found or can't stat — fall through to native read for error handling
      }

      // 3. Delegate everything else to native read
      const native = createReadToolDefinition(ctx.cwd);
      return native.execute(
        toolCallId,
        { path: rawPath, offset: params.offset, limit: params.limit },
        signal,
        onUpdate as any,
        ctx as any,
      );
    },
  };
}
