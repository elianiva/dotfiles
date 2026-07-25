import { Box, Markdown, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { StringEnum } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { getMarkdownTheme } from "@earendil-works/pi-coding-agent";
import { searchWeb, type SearchOptions } from "./search";
import { generateId, storeResult, type QueryResultData, type SearchResult } from "./storage";
import { formatCount, formatExpandHint, formatPublishedDate, formatStatusIcon, getDomain, progressBar, truncate } from "./render-utils";

/* ---- Render: Call ---- */

function renderCall(args: Record<string, unknown>, theme: Theme): Text {
  const raw: unknown[] = Array.isArray(args.queries) ? args.queries : args.query !== undefined ? [args.query] : [];
  const qs = raw.filter((q): q is string => typeof q === "string").map((q) => q.trim()).filter(Boolean);
  if (qs.length === 0) return new Text(theme.fg("toolTitle", theme.bold("search ")) + theme.fg("error", "(no query)"), 0, 0);

  const icon = formatStatusIcon("pending", theme);
  const title = theme.fg("toolTitle", theme.bold("Web Search"));

  if (qs.length === 1) {
    const d = truncate(qs[0], 60);
    return new Text(`${icon} ${title} ${theme.fg("accent", `"${d}"`)}`, 0, 0);
  }

  const lines = [`${icon} ${title} ${theme.fg("accent", `${qs.length} queries`)}`];
  for (const q of qs.slice(0, 5)) {
    const d = truncate(q, 50);
    lines.push(theme.fg("muted", `  "${d}"`));
  }
  if (qs.length > 5) lines.push(theme.fg("muted", `  ... and ${qs.length - 5} more`));
  return new Text(lines.join("\n"), 0, 0);
}

/* ---- Render: Result ---- */

/* ---- Helpers ---- */

function numVal(v: unknown, fallback = 0): number {
  return typeof v === "number" ? v : fallback;
}

function strVal(v: unknown, fallback = ""): string {
  return typeof v === "string" ? v : fallback;
}

function arrVal<T>(v: unknown): T[] {
  return Array.isArray(v) ? v as T[] : [];
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

  // Partial/loading state
  if (isPartial) {
    const p = progress ?? 0;
    const bar = progressBar(p);
    if (phase === "search" && currentQuery) {
      const display = truncate(currentQuery, 40);
      return new Text(theme.fg("accent", `[${bar}] ${display}`), 0, 0);
    }
    return new Text(theme.fg("accent", `[${bar}] ${phase ?? "searching"}`), 0, 0);
  }

  // Error state
  if (error) {
    const icon = formatStatusIcon("error", theme);
    return new Text(`${icon} ${theme.fg("error", `Web Search: ${error}`)}`, 0, 0);
  }

  const rawResults = arrVal<QueryResultData>(d.results);
  const totalSources = numVal(d.totalResults);
  const provider = strVal(d.provider) || rawResults[0]?.provider || "exa";
  const textContent = result.content.find((c) => c.type === "text")?.text || "";
  const hasSources = totalSources > 0 && rawResults.length > 0;

  // Collapsed: compact preview with source count
  if (!expanded) {
    const icon = formatStatusIcon("success", theme);
    const countLabel = formatCount("source", totalSources);
    const statusLine = `${icon} ${theme.fg("success", `Web Search`)} ${theme.fg("dim", `\u00B7`)} ${theme.fg("accent", countLabel)}`;
    const expandHint = formatExpandHint(theme, false, true);
    const box = new Box(1, 0, (t: string) => theme.bg("toolSuccessBg", t));
    box.addChild(new Text(`${statusLine}${expandHint}`, 0, 0));

    // Show first few source titles as preview
    if (hasSources) {
      const previewSources = rawResults.flatMap((qr) => qr.results).slice(0, 3);
      for (const src of previewSources) {
        const domain = getDomain(src.url);
        const domainStr = domain ? theme.fg("dim", ` (${domain})`) : "";
        box.addChild(new Text(theme.fg("dim", `  \u2022 ${truncate(src.title, 50)}${domainStr}`), 0, 0));
      }
      const totalSourcesFlat = rawResults.reduce((s, qr) => s + qr.results.length, 0);
      if (totalSourcesFlat > 3) {
        box.addChild(new Text(theme.fg("muted", `  ... and ${totalSourcesFlat - 3} more`), 0, 0));
      }
    }
    return box;
  }

  // Expanded: full structured output
  const icon = formatStatusIcon("success", theme);
  const providerLabel = provider === "exa" ? "Exa" : provider === "exa-mcp" ? "Exa (MCP)" : provider;
  const countLabel = formatCount("source", totalSources);
  const header = `${icon} ${theme.fg("success", "Web Search")} ${theme.fg("dim", "\u00B7")} ${theme.fg("muted", providerLabel)} ${theme.fg("dim", "\u00B7")} ${theme.fg("accent", countLabel)}`;

  const box = new Box(1, 1, (t: string) => theme.bg("toolSuccessBg", t));
  box.addChild(new Text(header, 0, 0));

  // Query preview
  const queries = arrVal<string>(d.queries);
  if (queries.length > 0) {
    const queryLine = queries.length === 1
      ? `${theme.fg("muted", "Query:")} ${theme.fg("text", truncate(queries[0], 80))}`
      : `${theme.fg("muted", `Queries (${queries.length}):`)} ${queries.map((q) => `"${truncate(q, 40)}"`).join(", ")}`;
    box.addChild(new Text(queryLine, 0, 0));
  }

  // Answer section
  if (textContent) {
    const answerTitle = theme.fg("toolTitle", theme.bold("Answer"));
    box.addChild(new Text(answerTitle, 0, 0));

    // Extract just the answer part (before "Sources:" section in the content)
    // The text content has the full output including sources list.
    // Use Markdown if there's substantial text content.
    const lines = textContent.split("\n");
    const answerLines: string[] = [];
    let inSources = false;
    for (const line of lines) {
      if (line.startsWith("---")) continue;
      if (line.startsWith("**Sources:**") || line.startsWith("Sources:")) {
        inSources = true;
        continue;
      }
      if (!inSources) answerLines.push(line);
    }
    const answerBody = answerLines.map((l) => l.trim()).filter(Boolean).join("\n").trim();

    if (answerBody) {
      const mdTheme = getMarkdownTheme();
      const md = new Markdown(answerBody, 0, 0, mdTheme);
      box.addChild(md);
    } else {
      box.addChild(new Text(theme.fg("muted", "No answer text returned"), 0, 0));
    }
  }

  // Sources section
  if (hasSources) {
    const sourceTitle = theme.fg("toolTitle", theme.bold("Sources"));
    box.addChild(new Text(sourceTitle, 0, 0));

    // Flatten all sources from all queries
    const allSources: Array<SearchResult & { queryIndex: number }> = rawResults
      .flatMap((qr, qi) =>
        qr.results.map((src) => ({ ...src, queryIndex: qi }))
      );

    for (let i = 0; i < allSources.length; i++) {
      const src = allSources[i];
      const num = `${i + 1}.`;
      const titleStr = src.title || "Untitled";
      const domain = getDomain(src.url);
      const age = formatPublishedDate(src.publishedDate);
      const metaParts: string[] = [];
      if (domain) metaParts.push(theme.fg("dim", `(${domain})`));
      if (age) metaParts.push(theme.fg("muted", age));
      const metaSuffix = metaParts.length > 0 ? ` ${metaParts.join(theme.fg("dim", " \u00B7 "))}` : "";
      // Multi-query: show which query this source belongs to
      const multiQueryTag = rawResults.length > 1 ? ` ${theme.fg("muted", `[q${src.queryIndex + 1}]`)}` : "";
      box.addChild(new Text(
        theme.fg("dim", `${num}`) + theme.fg("text", ` ${titleStr}`) + multiQueryTag + metaSuffix,
        0, 0,
      ));
      // Show URL on next line in dim
      box.addChild(new Text(theme.fg("muted", `   ${src.url}`), 0, 0));
    }
  }

  // Metadata section
  const metaTitle = theme.fg("toolTitle", theme.bold("Metadata"));
  box.addChild(new Text(metaTitle, 0, 0));
  const searchId = strVal(d.searchId);
  const successfulQueries = numVal(d.successfulQueries);
  const queryCount = numVal(d.queryCount);
  const metaLines: string[] = [
    `${theme.fg("muted", "Provider:")} ${theme.fg("text", providerLabel)}`,
  ];
  if (searchId) {
    metaLines.push(`${theme.fg("muted", "Search ID:")} ${theme.fg("dim", searchId)}`);
  }
  if (queryCount > 1) {
    metaLines.push(
      `${theme.fg("muted", "Queries:")} ${theme.fg("text", `${successfulQueries}/${queryCount} successful`)}`,
    );
  }
  box.addChild(new Text(metaLines.join("\n"), 0, 0));

  return box;
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

      // Collect provider info from all successful results
      const providers = allResults.filter((r) => !r.error && r.provider).map((r) => r.provider!);
      const dedupedProvider = [...new Set(providers)].join(", ");

      return {
        content: [{ type: "text" as const, text: output.trim() }],
        details: {
          queries: queryList,
          queryCount: queryList.length,
          successfulQueries: allResults.filter((r) => !r.error).length,
          totalResults: allResults.reduce((s, r) => s + r.results.length, 0),
          searchId,
          provider: dedupedProvider || undefined,
          results: allResults,
        },
      };
    },

    renderCall,
    renderResult,
  };
}
