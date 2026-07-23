/**
 * URL content extraction with Readability + turndown.
 *
 * Single fetch pipeline used by both `read http://` and (previously) `fetch_content`.
 * Features UA rotation, 429 retry, LRU caching, and Readability article extraction.
 */
import { Readability } from "@mozilla/readability";
import { parseHTML } from "linkedom";
import TurndownService from "turndown";
import { extractGitHub } from "./github-repo";
import { signalWithTimeout, readResponseBody, USER_AGENTS, isBotBlocked } from "./http-client";

const QUOTA_RESET_PATTERN = /reset after (?:(\d+)h)?(?:(\d+)m)?(\d+(?:\.\d+)?)s/i;
const PLEASE_RETRY_PATTERN = /Please retry in ([0-9.]+)(ms|s)/i;
const RETRY_DELAY_FIELD_PATTERN = /"retryDelay":\s*"([0-9.]+)(ms|s)"/i;
const TRY_AGAIN_PATTERN = /try again in\s+~?\s*([0-9.]+)\s*(ms|sec|s|minutes?|mins?|m|hours?|hrs?|h)\b/i;

function unitToMs(unit: string): number | undefined {
  switch (unit.toLowerCase()) {
    case "ms": return 1;
    case "s": case "sec": return 1000;
    case "m": case "min": case "mins": case "minute": case "minutes": return 60_000;
    case "h": case "hr": case "hrs": case "hour": case "hours": return 60 * 60_000;
    default: return undefined;
  }
}

function extractRetryHint(source: Response | Headers | null | undefined, body?: string): number | undefined {
  const headers = source instanceof Headers ? source : (source?.headers ?? undefined);
  if (headers) {
    const retryAfterMs = headers.get("retry-after-ms");
    if (retryAfterMs) {
      const ms = Number(retryAfterMs);
      if (Number.isFinite(ms) && ms >= 0) return ms;
    }
    const retryAfter = headers.get("retry-after");
    if (retryAfter) {
      const seconds = Number(retryAfter);
      if (Number.isFinite(seconds)) return Math.max(0, seconds * 1000);
      const parsedDate = Date.parse(retryAfter);
      if (!Number.isNaN(parsedDate)) return Math.max(0, parsedDate - Date.now());
    }
    const rateLimitResetMs = headers.get("x-ratelimit-reset-ms");
    if (rateLimitResetMs) {
      const value = Number(rateLimitResetMs);
      if (Number.isFinite(value) && value > 0) {
        const targetMs = value > 1e12 ? value : value > 1e9 ? value * 1000 : undefined;
        if (targetMs === undefined) return value;
        const delta = targetMs - Date.now();
        if (delta > 0) return delta;
      }
    }
    const rateLimitReset = headers.get("x-ratelimit-reset");
    if (rateLimitReset) {
      const resetSeconds = Number.parseInt(rateLimitReset, 10);
      if (!Number.isNaN(resetSeconds)) {
        const delta = resetSeconds * 1000 - Date.now();
        if (delta > 0) return delta;
      }
    }
    const rateLimitResetAfter = headers.get("x-ratelimit-reset-after");
    if (rateLimitResetAfter) {
      const seconds = Number(rateLimitResetAfter);
      if (Number.isFinite(seconds) && seconds > 0) return seconds * 1000;
    }
  }

  if (!body) return undefined;

  const quotaMatch = QUOTA_RESET_PATTERN.exec(body);
  if (quotaMatch) {
    const hours = quotaMatch[1] ? Number.parseInt(quotaMatch[1], 10) : 0;
    const minutes = quotaMatch[2] ? Number.parseInt(quotaMatch[2], 10) : 0;
    const seconds = Number.parseFloat(quotaMatch[3]!);
    if (!Number.isNaN(seconds)) {
      const totalMs = ((hours * 60 + minutes) * 60 + seconds) * 1000;
      if (totalMs > 0) return totalMs;
    }
  }
  for (const pattern of [PLEASE_RETRY_PATTERN, RETRY_DELAY_FIELD_PATTERN, TRY_AGAIN_PATTERN]) {
    const match = pattern.exec(body);
    if (match?.[1]) {
      const value = Number.parseFloat(match[1]);
      if (Number.isFinite(value) && value > 0) {
        const unitMs = unitToMs(match[2]!);
        if (unitMs !== undefined) return value * unitMs;
      }
    }
  }
  return undefined;
}
import { urlCache } from "../utils/cache";

const TIMEOUT_MS = 30_000;
const MAX_RESPONSE_BYTES = 5 * 1024 * 1024;
const MIN_CONTENT = 500;

const turndown = new TurndownService({
  headingStyle: "atx",
  codeBlockStyle: "fenced",
});

/* ---- Types ---- */

export interface ExtractedContent {
  url: string;
  title: string;
  content: string;
  error: string | null;
}

export interface ExtractOptions {
  prompt?: string;
  timestamp?: string;
  frames?: number;
  model?: string;
  forceClone?: boolean;
  /** Skip Readability/turndown, return raw body. */
  raw?: boolean;
}

/* ---- Main ---- */

export async function extractContent(
  url: string,
  signal?: AbortSignal,
  options?: ExtractOptions,
): Promise<ExtractedContent> {
  if (signal?.aborted) {
    return { url, title: "", content: "", error: "Aborted" };
  }

  // GitHub URL → clone/extract
  const githubResult = await extractGitHub(url, signal, options?.forceClone);
  if (githubResult) return githubResult;
  if (signal?.aborted) return { url, title: "", content: "", error: "Aborted" };

  // Check cache (not for raw requests)
  if (!options?.raw) {
    const cached = urlCache.get(url);
    if (cached !== undefined) {
      const titleLine = cached.split("\n")[0]?.replace(/^#\s*/, "") || url;
      return { url, title: titleLine, content: cached, error: null };
    }
  }

  let lastError: string | undefined;
  let retried429 = false;

  for (let attempt = 0; attempt < USER_AGENTS.length; attempt++) {
    if (signal?.aborted) return { url, title: "", content: "", error: "Aborted" };

    const { signal: combined, cleanup } = signalWithTimeout(signal, TIMEOUT_MS);

    try {
      const res = await fetch(url, {
        signal: combined,
        headers: {
          "User-Agent": USER_AGENTS[attempt],
          Accept:
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
          "Accept-Language": "en-US,en;q=0.9",
        },
        redirect: "follow",
      });

      // 429 retry once
      if (res.status === 429 && !retried429) {
        retried429 = true;
        const delay = Math.min(extractRetryHint(res.headers) ?? 2000, 10_000);
        cleanup();
        try { await res.body?.cancel(); } catch { /* ignore */ }
        await new Promise((r) => setTimeout(r, delay));
        continue;
      }

      if (!res.ok) {
        cleanup();
        const text = await readResponseBody(res, MAX_RESPONSE_BYTES);
        return { url, title: "", content: text, error: `HTTP ${res.status}: ${res.statusText}` };
      }

      const ct = (res.headers.get("content-type") ?? "").toLowerCase();

      // Unsupported binary types
      if (ct.includes("application/octet-stream") || ct.includes("image/") || ct.includes("audio/") || ct.includes("video/") || ct.includes("application/zip")) {
        cleanup();
        return { url, title: "", content: "", error: `Unsupported content type: ${ct.split(";")[0]}` };
      }

      const text = await readResponseBody(res, MAX_RESPONSE_BYTES);

      // Bot-block check — try next UA
      if (isBotBlocked(res.status, text) && attempt < USER_AGENTS.length - 1) {
        cleanup();
        continue;
      }

      // Non-HTML: return as-is
      if (!ct.includes("text/html") && !ct.includes("application/xhtml+xml")) {
        cleanup();
        return { url, title: extractTitle(text, url), content: text, error: null };
      }

      // Raw mode: skip Readability, use turndown on full HTML
      if (options?.raw) {
        const md = turndown.turndown(text).trim();
        urlCache.set(url, md);
        cleanup();
        return { url, title: extractTitle(md, url), content: md, error: null };
      }

      // HTML: use Readability for article extraction
      const { document } = parseHTML(text) as unknown as { document: Document };
      const article = new Readability(document).parse();

      if (!article) {
        const fallback = turndown.turndown(text).trim();
        urlCache.set(url, fallback);
        cleanup();
        return { url, title: extractTitle(fallback, url), content: fallback, error: "Could not extract readable content" };
      }

      const markdown = turndown.turndown(article.content);

      if (markdown.length < MIN_CONTENT) {
        urlCache.set(url, markdown);
        cleanup();
        return { url, title: article.title ?? "", content: markdown, error: "Extracted content appears incomplete" };
      }

      // Cache and return
      urlCache.set(url, markdown);
      cleanup();
      return { url, title: article.title ?? "", content: markdown, error: null };
    } catch (err) {
      cleanup();
      if (signal?.aborted) return { url, title: "", content: "", error: "Aborted" };
      lastError = err instanceof Error ? err.message : String(err);
      if (attempt === USER_AGENTS.length - 1) {
        return { url, title: "", content: "", error: lastError ?? "Unknown error" };
      }
    }
  }

  return { url, title: "", content: "", error: lastError ?? "Fetch failed" };
}

/* ---- Helpers ---- */

function extractTitle(text: string, url: string): string {
  const m = text.match(/^#{1,2}\s+(.+)/m);
  if (m) return m[1].replace(/\*+/g, "").trim();
  try {
    return new URL(url).pathname.split("/").pop() || url;
  } catch {
    return url;
  }
}
