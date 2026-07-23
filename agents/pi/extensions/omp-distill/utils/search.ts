/**
 * Minimal web search using Exa.
 *
 * Supports two modes:
 *   - EXA_API_KEY env var: uses Exa REST API (answer/search endpoints)
 *   - No API key: uses Exa MCP endpoint (free, no auth needed)
 *
 * Single provider, no fallback chain, no activity monitor.
 */
import type { SearchResult } from "./storage";

const EXA_ANSWER_URL = "https://api.exa.ai/answer";
const EXA_SEARCH_URL = "https://api.exa.ai/search";
const EXA_MCP_URL = "https://mcp.exa.ai/mcp";
const TIMEOUT_MS = 60_000;

/* ---- Response shapes ---- */

interface ExaCitation {
  url?: string;
  title?: string;
  text?: string;
  publishedDate?: string;
}

interface ExaAnswerResponse {
  answer?: string;
  citations?: ExaCitation[];
}

interface ExaSearchItem {
  title?: string;
  url?: string;
  text?: string;
  highlights?: string[];
}

interface ExaSearchResponse {
  results?: ExaSearchItem[];
}

interface ExaMcpItem {
  title: string;
  url: string;
  content: string;
}

/* ---- Public API ---- */

export interface SearchOptions {
  numResults?: number;
  recencyFilter?: "day" | "week" | "month" | "year";
  domainFilter?: string[];
  signal?: AbortSignal;
}

export interface SearchOutput {
  answer: string;
  results: SearchResult[];
  provider: string;
}

export async function searchWeb(
  query: string,
  options: SearchOptions = {},
): Promise<SearchOutput> {
  const apiKey = process.env.EXA_API_KEY?.trim();
  return apiKey ? searchWithRestApi(query, apiKey, options) : searchWithMcp(query, options);
}

/* ---- REST API (needs EXA_API_KEY) ---- */

async function searchWithRestApi(
  query: string,
  apiKey: string,
  options: SearchOptions,
): Promise<SearchOutput> {
  const numResults = clamp(options.numResults ?? 5);

  // Answer API is simpler but only supports basic queries
  if (numResults <= 5 && !options.recencyFilter && !options.domainFilter) {
    const body = { query, text: true };
    const res = await post(EXA_ANSWER_URL, body, apiKey, options.signal);
    const data = (await res.json()) as ExaAnswerResponse;
    return {
      answer: data.answer ?? "",
      results: mapCitations(data.citations ?? []),
      provider: "exa",
    };
  }

  // Search API for advanced options
  const body: Record<string, unknown> = {
    query,
    type: "auto",
    numResults,
    contents: { text: { maxCharacters: 3000 }, highlights: true },
  };
  if (options.recencyFilter) {
    body.startPublishedDate = recencyToDate(options.recencyFilter);
  }
  if (options.domainFilter?.length) {
    applyDomainFilter(body, options.domainFilter);
  }

  const res = await post(EXA_SEARCH_URL, body, apiKey, options.signal);
  const data = (await res.json()) as ExaSearchResponse;

  return {
    answer: buildAnswer(data.results ?? []),
    results: mapSearchResults(data.results ?? []),
    provider: "exa",
  };
}

/* ---- MCP endpoint (free, no API key) ---- */

async function searchWithMcp(
  query: string,
  options: SearchOptions,
): Promise<SearchOutput> {
  const numResults = clamp(options.numResults ?? 5);
  const enriched = buildMcpQuery(query, options);

  const text = await callMcp(enriched, numResults, options.signal);
  const items = parseMcpResults(text);

  if (!items || items.length === 0) {
    return { answer: "", results: [], provider: "exa-mcp" };
  }

  const answer = items
    .map((it) => `${it.content}\nSource: ${it.title} (${it.url})`)
    .join("\n\n");

  return {
    answer,
    results: items.map((it, i) => ({
      title: it.title || `Source ${i + 1}`,
      url: it.url,
      snippet: it.content.replace(/\s+/g, " ").trim().slice(0, 300),
    })),
    provider: "exa-mcp",
  };
}

/* ---- HTTP helpers ---- */

function signalWithTimeout(signal?: AbortSignal): AbortSignal {
  const timeout = AbortSignal.timeout(TIMEOUT_MS);
  return signal ? AbortSignal.any([signal, timeout]) : timeout;
}

async function post(url: string, body: unknown, apiKey: string, signal?: AbortSignal): Promise<Response> {
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
    signal: signalWithTimeout(signal),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Exa ${res.status}: ${text.slice(0, 300)}`);
  }
  return res;
}

/* ---- MCP ---- */

async function callMcp(query: string, numResults: number, signal?: AbortSignal): Promise<string> {
  const body = JSON.stringify({
    jsonrpc: "2.0",
    id: 1,
    method: "tools/call",
    params: { name: "web_search_exa", arguments: { query, numResults, livecrawl: "fallback", type: "auto" } },
  });

  const res = await fetch(EXA_MCP_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json, text/event-stream" },
    body,
    signal: signalWithTimeout(signal),
  });

  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Exa MCP ${res.status}: ${text.slice(0, 300)}`);
  }

  const raw = await res.text();

  // Parse SSE data: lines prefixed with "data:"
  for (const line of raw.split("\n").filter((l) => l.startsWith("data:"))) {
    const payload = line.slice(5).trim();
    if (!payload) continue;
    try {
      const parsed = JSON.parse(payload) as {
        result?: { content?: Array<{ type?: string; text?: string }>; isError?: boolean };
        error?: { code?: number; message?: string };
      };
      if (parsed.error) {
        throw new Error(parsed.error.message ?? "Exa MCP error");
      }
      if (parsed.result?.isError) {
        const msg = parsed.result.content?.find((c) => c.type === "text")?.text ?? "Exa MCP error";
        throw new Error(msg);
      }
      const text = parsed.result?.content?.find((c) => c.type === "text" && c.text)?.text;
      if (text) return text;
    } catch {
      // skip malformed lines
    }
  }

  // Fallback: try parsing entire response as JSON
  try {
    const parsed = JSON.parse(raw) as {
      result?: { content?: Array<{ type?: string; text?: string }> };
    };
    const text = parsed.result?.content?.find((c) => c.type === "text" && c.text)?.text;
    if (text) return text;
  } catch {
    // not JSON
  }

  throw new Error("Exa MCP returned empty response");
}

function parseMcpResults(text: string): ExaMcpItem[] | null {
  const blocks = text.split(/(?=^Title: )/m).filter((b) => b.trim().length > 0);
  const items = blocks
    .map((block) => {
      const title = block.match(/^Title: (.+)/m)?.[1]?.trim() ?? "";
      const url = block.match(/^URL: (.+)/m)?.[1]?.trim() ?? "";
      let content = "";
      const textStart = block.indexOf("\nText: ");
      if (textStart >= 0) {
        content = block.slice(textStart + 7).trim();
      }
      content = content.replace(/\n---\s*$/, "").trim();
      return { title, url, content };
    })
    .filter((r) => r.url.length > 0);
  return items.length > 0 ? items : null;
}

/* ---- Mapping ---- */

function mapCitations(citations: ExaCitation[]): SearchResult[] {
  return citations
    .filter((c) => c.url)
    .map((c) => ({ title: c.title ?? "Source", url: c.url!, snippet: c.text ?? "" }));
}

function mapSearchResults(results: ExaSearchItem[]): SearchResult[] {
  return results
    .filter((r) => r.url)
    .map((r) => ({
      title: r.title ?? "Source",
      url: r.url!,
      snippet: (r.highlights?.join(" ") ?? r.text ?? "").replace(/\s+/g, " ").trim().slice(0, 500),
    }));
}

function buildAnswer(results: ExaSearchItem[]): string {
  return results
    .filter((r) => r.url)
    .map((r, i) => {
      const content = (r.highlights?.join(" ") ?? r.text ?? "").trim().slice(0, 1000);
      return content ? `${content}\nSource: ${r.title ?? `Source ${i + 1}`} (${r.url})` : "";
    })
    .filter(Boolean)
    .join("\n\n");
}

/* ---- Helpers ---- */

function clamp(n: number): number {
  return Math.max(1, Math.min(Math.floor(n), 20));
}

function recencyToDate(filter: string): string {
  const days: Record<string, number> = { day: 1, week: 7, month: 30, year: 365 };
  const d = new Date(Date.now() - (days[filter] ?? 0) * 86400000);
  return d.toISOString();
}

function applyDomainFilter(body: Record<string, unknown>, filters: string[]): void {
  const includes: string[] = [];
  const excludes: string[] = [];
  for (const f of filters) {
    if (f.startsWith("-")) excludes.push(f.slice(1).trim());
    else includes.push(f.trim());
  }
  if (includes.length) body.includeDomains = includes;
  if (excludes.length) body.excludeDomains = excludes;
}

function buildMcpQuery(query: string, options: SearchOptions): string {
  const parts = [query];
  if (options.domainFilter?.length) {
    for (const d of options.domainFilter) {
      parts.push(d.startsWith("-") ? `-site:${d.slice(1)}` : `site:${d}`);
    }
  }
  if (options.recencyFilter) {
    const labels: Record<string, string> = { day: "past 24 hours", week: "past week", month: "past month", year: "past year" };
    parts.push(labels[options.recencyFilter] ?? "");
  }
  return parts.join(" ");
}
