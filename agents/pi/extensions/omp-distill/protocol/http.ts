/**
 * HTTP/S protocol handler for the read tool.
 *
 * Delegates to the shared fetch pipeline in fetch-content.ts.
 * Supports :raw, :N, :N-M, :N+K selectors via parseReadSelector.
 */
import type { ProtocolHandler } from "./types";
import { parseReadSelector } from "../utils/utils";
import { extractContent } from "./fetch-content";

function formatResult(url: string, title: string, content: string, error: string | null): string {
  if (error) {
    return `URL: ${url}\nError: ${error}`;
  }
  const header = title ? `URL: ${url}\nTitle: ${title}` : `URL: ${url}`;
  return `${header}\n\n---\n\n${content}`;
}

/** Protocol handler for http:// and https:// URLs. */
export const httpHandler: ProtocolHandler = {
  scheme: "http",
  matches: (path) => /^https?:\/\//i.test(path),
  async resolve(path, ctx) {
    const { basePath, raw, offset, limit } = parseReadSelector(path);
    const result = await extractContent(basePath, ctx.signal, { raw });

    let output = formatResult(result.url, result.title, result.content, result.error);

    // Apply line offset/limit selectors (:N, :N-M, :N+K)
    const bodyLines = output.split("\n");
    if (offset !== undefined) {
      const start = Math.max(0, offset - 1);
      const end = limit !== undefined ? start + limit : bodyLines.length;
      output = bodyLines.slice(start, end).join("\n");
      if (end < bodyLines.length) {
        output += `\n\n[${bodyLines.length - end} more lines. Use offset=${end + 1} to continue]`;
      }
    }

    return {
      content: [{ type: "text", text: output }],
      details: {},
      isError: result.error !== null,
    };
  },
};
