import { Box, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { searchWeb, type SearchOptions } from "../utils/search";
import { generateId, storeResult, type QueryResultData } from "../utils/storage";
import { progressBar, truncate } from "../utils/render-utils";

/* ---- Render ---- */

function renderCall(args: Record<string, unknown>, theme: Theme): Text {
  const raw: unknown[] = Array.isArray(args.queries) ? args.queries : args.query !== undefined ? [args.query] : [];
  const qs = raw.filter((q): q is string => typeof q === "string").map((q) => q.trim()).filter(Boolean);
  if (qs.length === 0) return new Text(theme.fg("toolTitle", theme.bold("search ")) + theme.fg("error", "(no query)"), 0, 0);
  if (qs.length === 1) {
    const d = truncate(qs[0], 60);
    return new Text(theme.fg("toolTitle", theme.bold("search ")) + theme.fg("accent", `"${d}"`), 0, 0);
  }
  const lines = [theme.fg("toolTitle", theme.bold("search ")) + theme.fg("accent", `${qs.length} queries`)];
  for (const q of qs.slice(0, 5)) {
    const d = truncate(q, 50);
    lines.push(theme.fg("muted", `  "${d}"`));
  }
  if (qs.length > 5) lines.push(theme.fg("muted", `  ... and ${qs.length - 5} more`));
  return new Text(lines.join("\n"), 0, 0);
}

function renderResult(
  result: { content: Array<{ type: string; text?: string }>; details?: Record<string, unknown> },
  { expanded, isPartial }: { expanded: boolean; isPartial: boolean },
  theme: Theme,
): Text | Box {
  const d = result.details ?? {};
  const error = d.error as string | undefined;
  const phase = d.phase as string | undefined;
  const progress = d.progress as number | undefined;
  const currentQuery = d.currentQuery as string | undefined;

  if (isPartial) {
    const p = progress ?? 0;
    const bar = progressBar(p);
    if (phase === "search" && currentQuery) {
      const display = truncate(currentQuery, 40);
      return new Text(theme.fg("accent", `[${bar}] ${display}`), 0, 0);
    }
    return new Text(theme.fg("accent", `[${bar}] ${phase ?? "searching"}`), 0, 0);
  }

  if (error) return new Text(theme.fg("error", `Error: ${error}`), 0, 0);

  const qc = d.queryCount === 1 ? "" : `${d.successfulQueries}/${d.queryCount} queries, `;
  const statusLine = theme.fg("success", `${qc}${d.totalResults ?? 0} sources`);
  const textContent = result.content.find((c) => c.type === "text")?.text || "";

  if (!expanded) {
    const box = new Box(1, 0, (t: string) => theme.bg("toolSuccessBg", t));
    box.addChild(new Text(statusLine, 0, 0));
    const preview = truncate(textContent, 200);
    if (preview) box.addChild(new Text(theme.fg("dim", preview), 0, 0));
    return box;
  }

  const lines = [statusLine];
  const preview = truncate(textContent, 500);
  for (const line of preview.split("\n")) lines.push(theme.fg("dim", line));
  return new Text(lines.join("\n"), 0, 0);
}

/* ---- Params ---- */

const params = Type.Object({
  query: Type.Optional(Type.String({ description: "Single search query. Prefer 'queries' for multiple angles." })),
  queries: Type.Optional(Type.Array(Type.String(), { description: "Multiple queries searched in sequence. Vary phrasing, scope, and angle across 2-4 queries." })),
  numResults: Type.Optional(Type.Number({ description: "Results per query (default: 5, max: 20)" })),
  recencyFilter: Type.Optional(StringEnum(["day", "week", "month", "year"], { description: "Filter by recency" })),
  domainFilter: Type.Optional(Type.Array(Type.String(), { description: "Limit to domains (prefix with - to exclude)" })),
});

type Params = {
  query?: string; queries?: string[]; numResults?: number;
  recencyFilter?: "day" | "week" | "month" | "year"; domainFilter?: string[];
};

/* ---- Tool ---- */

export function createWebSearchTool(pi: ExtensionAPI) {
  return {
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web using Exa. Returns an AI-synthesized answer with source citations. " +
      "For comprehensive research, prefer queries (plural) with 2-4 varied angles over a single query. " +
      "Requires EXA_API_KEY env var for advanced features; works without one via Exa MCP (free).",
    promptSnippet: "Use for web research questions. Prefer {queries:[...]} with 2-4 varied angles over a single query for broader coverage.",
    parameters: params,

    async execute(_callId: string, params: Params, signal: AbortSignal | undefined, onUpdate: ((u: { content: Array<{ type: string; text: string }>; details?: Record<string, unknown> }) => void) | undefined) {
      const rawQueries = Array.isArray(params.queries) ? params.queries : params.query ? [params.query] : [];
      const queryList = rawQueries.filter((q): q is string => typeof q === "string").map((q) => q.trim()).filter(Boolean);
      if (queryList.length === 0) return { content: [{ type: "text" as const, text: "Error: No query provided." }], details: { error: "No query provided" } };

      const allResults: QueryResultData[] = [];
      const opts: SearchOptions = { numResults: params.numResults, recencyFilter: params.recencyFilter, domainFilter: params.domainFilter, signal };

      for (let i = 0; i < queryList.length; i++) {
        onUpdate?.({ content: [{ type: "text", text: `Searching ${i + 1}/${queryList.length}: "${queryList[i]}"...` }], details: { phase: "search", progress: i / queryList.length, currentQuery: queryList[i] } });
        try {
          const { answer, results, provider } = await searchWeb(queryList[i], opts);
          allResults.push({ query: queryList[i], answer, results, error: null, provider });
        } catch (err) {
          allResults.push({ query: queryList[i], answer: "", results: [], error: err instanceof Error ? err.message : String(err) });
        }
      }

      const searchId = generateId();
      storeResult(searchId, { id: searchId, type: "search", timestamp: Date.now(), queries: allResults });
      pi.appendEntry("web-search-results", { id: searchId, type: "search", timestamp: Date.now(), queries: allResults });

      let output = "";
      for (const r of allResults) {
        if (queryList.length > 1) output += `## Query: "${r.query}"\n\n`;
        if (r.error) { output += `Error: ${r.error}\n\n`; continue; }
        output += r.answer ? `${r.answer}\n\n---\n\n**Sources:**\n` : "**Sources:**\n";
        output += r.results.map((s, i) => `${i + 1}. ${s.title}\n   ${s.url}`).join("\n\n") + "\n\n";
      }
      output += `\n---\nResults are shown inline above. Use web_search again with refined queries for more detail.`;

      return {
        content: [{ type: "text" as const, text: output.trim() }],
        details: { queries: queryList, queryCount: queryList.length, successfulQueries: allResults.filter((r) => !r.error).length, totalResults: allResults.reduce((s, r) => s + r.results.length, 0), searchId },
      };
    },

    renderCall,
    renderResult,
  };
}
