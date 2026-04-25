import { FileFinder } from "@ff-labs/fff-node";
import { Type } from "@sinclair/typebox";
import { resolve } from "node:path";
import type { BuiltinTool } from "./builtins.js";
import type { FffToolName } from "./types.js";

// Global instance cache
const finderCache = new Map<string, FileFinder>();

async function getFinder(cwd: string, searchPath?: string): Promise<FileFinder> {
  const basePath = resolve(cwd, searchPath || ".");
  if (!finderCache.has(basePath)) {
    const result = FileFinder.create({ basePath });
    if (!result.ok) throw new Error(result.error || "unknown");
    finderCache.set(basePath, result.value);
    result.value.waitForScan(5000).catch(() => console.log("fff scan timeout"));
  }
  return finderCache.get(basePath)!;
}

// Eagerly initialize finder for a path (call on session start)
export async function initFinder(cwd: string, searchPath?: string): Promise<void> {
  await getFinder(cwd, searchPath);
}

export function destroyAllFinders(): void {
  for (const f of finderCache.values()) f.destroy();
  finderCache.clear();
}

// Grep tool
export const grepTool: BuiltinTool = {
  name: "grep",
  description: "Search file contents using fff (SIMD-accelerated). Use as tools.fff.grep()",
  parameters: Type.Object({
    pattern: Type.String(),
    path: Type.Optional(Type.String()),
    mode: Type.Optional(
      Type.Union([Type.Literal("plain"), Type.Literal("regex"), Type.Literal("fuzzy")]),
    ),
    smartCase: Type.Optional(Type.Boolean()),
    glob: Type.Optional(Type.String()),
    maxMatchesPerFile: Type.Optional(Type.Number()),
    context: Type.Optional(Type.Number()),
    classifyDefinitions: Type.Optional(Type.Boolean()),
    limit: Type.Optional(Type.Number()),
  }),
  execute: async (_id: string, args: any, cwd: string) => {
    const finder = await getFinder(cwd, args.path);
    const query = args.glob ? args.glob + " " + args.pattern : args.pattern;
    const res = finder.grep(query, {
      mode: args.mode || "plain",
      maxFileSize: args.maxFileSize || 0,
      maxMatchesPerFile: args.maxMatchesPerFile || 0,
      smartCase: args.smartCase ?? true,
      beforeContext: args.context || 0,
      afterContext: args.context || 0,
      classifyDefinitions: args.classifyDefinitions || false,
    } as any);
    if (!res.ok) throw new Error(res.error);
    const items = args.limit ? res.value.items.slice(0, args.limit) : res.value.items;
    return {
      matches: items.map((m: any) => ({
        path: m.relativePath,
        line: m.lineNumber,
        column: m.col,
        content: m.lineContent,
        matchRanges: m.matchRanges,
        isDefinition: m.isDefinition ?? false,
      })),
      totalMatched: res.value.totalMatched,
      totalFilesSearched: res.value.totalFilesSearched,
      nextCursor: res.value.nextCursor,
    };
  },
};

// File search tool
export const fileSearchTool: BuiltinTool = {
  name: "fileSearch",
  description: "Fuzzy search for files by path. Use as tools.fff.fileSearch()",
  parameters: Type.Object({
    query: Type.String(),
    path: Type.Optional(Type.String()),
    limit: Type.Optional(Type.Number()),
  }),
  execute: async (_id: string, args: any, cwd: string) => {
    const finder = await getFinder(cwd, args.path);
    const res = finder.fileSearch(args.query, { pageSize: args.limit || 20 });
    if (!res.ok) throw new Error(res.error);
    return {
      files: res.value.items.map((item: any) => ({
        path: item.relativePath,
        name: item.fileName,
        gitStatus: item.gitStatus,
        frecencyScore: item.totalFrecencyScore,
      })),
    };
  },
};

// Multi-pattern grep
export const multiGrepTool: BuiltinTool = {
  name: "multiGrep",
  description: "Multi-pattern search (OR logic). Use as tools.fff.multiGrep()",
  parameters: Type.Object({
    patterns: Type.Array(Type.String()),
    path: Type.Optional(Type.String()),
    limit: Type.Optional(Type.Number()),
  }),
  execute: async (_id: string, args: any, cwd: string) => {
    const finder = await getFinder(cwd, args.path);
    const res = finder.multiGrep({
      patterns: args.patterns,
      smartCase: true,
    });
    if (!res.ok) throw new Error(res.error);
    const items = args.limit ? res.value.items.slice(0, args.limit) : res.value.items;
    return {
      matches: items.map((m: any) => ({
        path: m.relativePath,
        line: m.lineNumber,
        content: m.lineContent,
      })),
    };
  },
};

// Recent files
export const recentFilesTool: BuiltinTool = {
  name: "recentFiles",
  description: "Get recently accessed files (frecency). Use as tools.fff.recentFiles()",
  parameters: Type.Object({
    path: Type.Optional(Type.String()),
    limit: Type.Optional(Type.Number()),
    minFrecencyScore: Type.Optional(Type.Number()),
    includeUntracked: Type.Optional(Type.Boolean()),
  }),
  execute: async (_id: string, args: any, cwd: string) => {
    const finder = await getFinder(cwd, args.path);
    const res = finder.fileSearch("", { pageSize: (args.limit || 20) * 2 });
    if (!res.ok) throw new Error(res.error);
    let files = res.value.items.map((item: any, i: number) => ({
      path: item.relativePath,
      name: item.fileName,
      gitStatus: item.gitStatus,
      frecencyScore: res.value.scores[i]?.baseScore || 0,
    }));
    if (args.minFrecencyScore)
      files = files.filter((f: any) => f.frecencyScore >= args.minFrecencyScore);
    if (args.includeUntracked === false) files = files.filter((f: any) => f.gitStatus !== "??");
    if (args.limit) files = files.slice(0, args.limit);
    return { files };
  },
};

// Search then grep
export const searchThenGrepTool: BuiltinTool = {
  name: "searchThenGrep",
  description: "Fuzzy search files then grep within. Use as tools.fff.searchThenGrep()",
  parameters: Type.Object({
    pathQuery: Type.String(),
    contentQuery: Type.String(),
    path: Type.Optional(Type.String()),
    maxFiles: Type.Optional(Type.Number()),
    limit: Type.Optional(Type.Number()),
  }),
  execute: async (_id: string, args: any, cwd: string) => {
    const finder = await getFinder(cwd, args.path);
    const fileRes = finder.fileSearch(args.pathQuery, { pageSize: args.maxFiles || 50 });
    if (!fileRes.ok) throw new Error(fileRes.error);
    if (fileRes.value.items.length === 0) return { matches: [], fileMatches: 0 };
    const paths = fileRes.value.items.map((item: any) => item.relativePath);
    const res = finder.grep(args.contentQuery + " " + paths.join(" "), { mode: "plain" });
    if (!res.ok) throw new Error(res.error);
    const items = args.limit ? res.value.items.slice(0, args.limit) : res.value.items;
    return {
      matches: items.map((m: any) => ({
        path: m.relativePath,
        line: m.lineNumber,
        content: m.lineContent,
      })),
      fileMatches: paths.length,
      totalMatched: res.value.totalMatched,
    };
  },
};

export type FffBuiltinToolset = Record<FffToolName, BuiltinTool>;

export function createFffBuiltinToolset(cwd: string): FffBuiltinToolset {
  const withCwd = (tool: BuiltinTool): BuiltinTool => ({
    ...tool,
    execute: async (_toolCallId: string, args: any, _signal: any, _onUpdate: any) =>
      tool.execute(_toolCallId, args, cwd),
  });

  return {
    grep: withCwd(grepTool),
    fileSearch: withCwd(fileSearchTool),
    multiGrep: withCwd(multiGrepTool),
    recentFiles: withCwd(recentFilesTool),
    searchThenGrep: withCwd(searchThenGrepTool),
  };
}