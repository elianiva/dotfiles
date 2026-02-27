/**
 * WebFetch Extension
 *
 * Fetches web content and converts to markdown, text, or HTML for agent consumption.
 * Use when URLs are mentioned in conversation to retrieve their content.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { StringEnum } from "@mariozechner/pi-ai";
import TurndownService from "turndown";

const MAX_RESPONSE_SIZE = 5 * 1024 * 1024; // 5MB
const DEFAULT_TIMEOUT = 30 * 1000; // 30 seconds
const MAX_TIMEOUT = 120 * 1000; // 2 minutes

// Turndown instance for HTML to Markdown conversion
const turndownService = new TurndownService({
  headingStyle: "atx",
  hr: "---",
  bulletListMarker: "-",
  codeBlockStyle: "fenced",
  emDelimiter: "*",
});

// Remove script/style/meta/link tags
turndownService.remove(["script", "style", "meta", "link", "noscript"]);

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "webfetch",
    label: "WebFetch",
    description:
      "Fetch web content and convert to markdown, text, or HTML for analysis. " +
      "Use when URLs are mentioned in conversation to retrieve their content. " +
      "HTTP URLs are automatically upgraded to HTTPS. " +
      "Images and binary content return empty text.",

    parameters: Type.Object({
      url: Type.String({ description: "The URL to fetch content from" }),
      format: Type.Optional(
        StringEnum(["markdown", "text", "html"] as const, {
          description: "Output format: markdown (default), text, or html",
        }),
      ),
      timeout: Type.Optional(
        Type.Number({
          description: "Timeout in seconds (max 120, default 30)",
        }),
      ),
    }),

    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      const format = params.format ?? "markdown";
      let url = params.url;

      // Validate and normalize URL
      if (url.startsWith("http://")) {
        url = url.replace("http://", "https://");
      }
      if (!url.startsWith("https://")) {
        ctx.ui.notify("Invalid URL: must start with http:// or https://", "error");
        return {
          content: [{ type: "text", text: "" }],
          details: { url: params.url, format, error: "Invalid URL" },
        };
      }

      const timeout = Math.min(
        (params.timeout ?? DEFAULT_TIMEOUT / 1000) * 1000,
        MAX_TIMEOUT,
      );

      // Create abort controller that combines signal and timeout
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      // Link external signal if provided
      if (signal) {
        signal.addEventListener("abort", () => controller.abort());
      }

      try {
        const response = await fetch(url, {
          signal: controller.signal,
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept:
              "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
          },
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          ctx.ui.notify(`HTTP error ${response.status}: ${response.statusText}`, "error");
          return {
            content: [{ type: "text", text: "" }],
            details: {
              url,
              format,
              error: `HTTP ${response.status}`,
            },
          };
        }

        // Check content length header
        const contentLength = response.headers.get("content-length");
        if (contentLength && parseInt(contentLength) > MAX_RESPONSE_SIZE) {
          ctx.ui.notify("Response too large (>5MB)", "error");
          return {
            content: [{ type: "text", text: "" }],
            details: { url, format, error: "Response too large" },
          };
        }

        const contentType = response.headers.get("content-type") || "";
        const mime = contentType.split(";")[0]?.trim().toLowerCase() || "";

        // Skip binary/image content - return empty for agent
        if (
          mime.startsWith("image/") ||
          mime.startsWith("video/") ||
          mime.startsWith("audio/") ||
          mime.startsWith("application/pdf") ||
          mime.startsWith("application/zip") ||
          mime.startsWith("application/octet-stream")
        ) {
          return {
            content: [{ type: "text", text: "" }],
            details: { url, format, contentType: mime, skipped: true },
          };
        }

        const arrayBuffer = await response.arrayBuffer();

        if (arrayBuffer.byteLength > MAX_RESPONSE_SIZE) {
          ctx.ui.notify("Response too large (>5MB)", "error");
          return {
            content: [{ type: "text", text: "" }],
            details: { url, format, error: "Response too large" },
          };
        }

        const text = new TextDecoder().decode(arrayBuffer);

        // Process based on format
        let output = "";
        switch (format) {
          case "markdown": {
            if (mime.includes("text/html")) {
              output = turndownService.turndown(text);
            } else {
              output = text;
            }
            break;
          }
          case "text": {
            if (mime.includes("text/html")) {
              output = htmlToText(text);
            } else {
              output = text;
            }
            break;
          }
          case "html": {
            output = text;
            break;
          }
        }

        // Clean up whitespace
        output = output.trim();

        return {
          content: [{ type: "text", text: output }],
          details: { url, format, contentType: mime },
        };
      } catch (error) {
        clearTimeout(timeoutId);

        if (error instanceof Error) {
          if (error.name === "AbortError") {
            ctx.ui.notify("Request timed out or was cancelled", "error");
            return {
              content: [{ type: "text", text: "" }],
              details: { url, format, error: "Timeout or cancelled" },
            };
          }
          ctx.ui.notify(`Fetch error: ${error.message}`, "error");
          return {
            content: [{ type: "text", text: "" }],
            details: { url, format, error: error.message },
          };
        }

        ctx.ui.notify("Unknown error occurred", "error");
        return {
          content: [{ type: "text", text: "" }],
          details: { url, format, error: "Unknown error" },
        };
      }
    },
  });
}

// Simple HTML to text conversion (no turndown for text format)
function htmlToText(html: string): string {
  return (
    html
      // Remove script/style tags and their content
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
      // Replace common block elements with newlines
      .replace(/<\/p>/gi, "\n\n")
      .replace(/<br\s*\/?>/gi, "\n")
      .replace(/<\/div>/gi, "\n")
      .replace(/<\/h[1-6]>/gi, "\n\n")
      .replace(/<\/li>/gi, "\n")
      // Remove all remaining tags
      .replace(/<[^>]+>/g, "")
      // Decode common HTML entities
      .replace(/&nbsp;/g, " ")
      .replace(/&amp;/g, "&")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      // Clean up whitespace
      .replace(/\n{3,}/g, "\n\n")
      .trim()
  );
}
