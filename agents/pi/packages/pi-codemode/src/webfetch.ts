import TurndownService from "turndown";

export type WebfetchInput = {
  url: string;
  format?: "markdown" | "text" | "html";
  timeout?: number;
};

const MAX_RESPONSE_SIZE = 5 * 1024 * 1024;
const DEFAULT_TIMEOUT = 30 * 1000;
const MAX_TIMEOUT = 120 * 1000;

const turndownService = new TurndownService();

// Simple HTML to text conversion
function htmlToText(html: string): string {
  return (
    html
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
      .replace(/<\/p>/gi, "\n\n")
      .replace(/<br\s*\/?>/gi, "\n")
      .replace(/<\/div>/gi, "\n")
      .replace(/<\/h[1-6]>/gi, "\n\n")
      .replace(/<\/li>/gi, "\n")
      .replace(/<[^>]+>/g, "")
      .replace(/&nbsp;/g, " ")
      .replace(/&amp;/g, "&")
      .replace(/&lt;/g, "<")
      .replace(/&gt;/g, ">")
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/\n{3,}/g, "\n\n")
      .trim()
  );
}

function htmlToMarkdown(html: string): string {
  try {
    return turndownService.turndown(html);
  } catch {
    return htmlToText(html);
  }
}

export async function webfetch(
  _toolId: string,
  args: WebfetchInput,
  _signal: AbortSignal | undefined,
  _onUpdate: () => void,
): Promise<{ content: Array<{ type: "text"; text: string }>; details?: Record<string, unknown> }> {
  const format = args.format ?? "markdown";
  let url = args.url;

  if (url.startsWith("http://")) {
    try {
      const parsed = new URL(url);
      const isLocalhost = parsed.hostname === "localhost" || parsed.hostname === "127.0.0.1" || parsed.hostname === "::1";
      if (!isLocalhost) {
        url = url.replace("http://", "https://");
      }
    } catch {
      return {
        content: [{ type: "text", text: "" }],
        details: { url: args.url, format, error: "Invalid URL" },
      };
    }
  }
  if (!url.startsWith("https://")) {
    return {
      content: [{ type: "text", text: "" }],
      details: { url: args.url, format, error: "Invalid URL" },
    };
  }

  const timeout = Math.min((args.timeout ?? DEFAULT_TIMEOUT / 1000) * 1000, MAX_TIMEOUT);
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
      },
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      return {
        content: [{ type: "text", text: "" }],
        details: { url, format, error: `HTTP ${response.status}` },
      };
    }

    const contentLength = response.headers.get("content-length");
    if (contentLength && parseInt(contentLength) > MAX_RESPONSE_SIZE) {
      return {
        content: [{ type: "text", text: "" }],
        details: { url, format, error: "Response too large" },
      };
    }

    const contentType = response.headers.get("content-type") || "";
    const mime = contentType.split(";")[0]?.trim().toLowerCase() || "";

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
      return {
        content: [{ type: "text", text: "" }],
        details: { url, format, error: "Response too large" },
      };
    }

    let text = new TextDecoder().decode(arrayBuffer);
    let output = "";

    switch (format) {
      case "markdown":
        output = mime.includes("text/html") ? htmlToMarkdown(text) : text;
        break;
      case "text":
        output = mime.includes("text/html") ? htmlToText(text) : text;
        break;
      case "html":
        output = text;
        break;
    }

    return {
      content: [{ type: "text", text: output.trim() }],
      details: { url, format, contentType: mime },
    };
  } catch (error) {
    clearTimeout(timeoutId);
    const errorMsg = error instanceof Error ? error.message : "Unknown error";
    return {
      content: [{ type: "text", text: "" }],
      details: { url, format, error: errorMsg },
    };
  }
}