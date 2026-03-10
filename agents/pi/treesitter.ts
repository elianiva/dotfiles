import path from "node:path";
import fs from "node:fs/promises";
import { createWriteStream } from "node:fs";
import os from "node:os";
import https from "node:https";
import Parser from "tree-sitter";
import { createPicker } from "../create-picker";
import type { PickerContext } from "../types";

interface ParserConfig {
  /** Language identifier (e.g., "typescript", "rust") */
  language: string;
  /** File extensions to scan (e.g., [".ts", ".tsx"]) */
  extensions: string[];
  /** URL to download the parser WASM */
  url?: string;
  /** Optional local path to parser (instead of URL) */
  localPath?: string;
}

interface Symbol {
  name: string;
  kind: string;
  file: string;
  line: number;
  column: number;
}

/** Simple LRU cache with max size limit */
class LRUCache<K, V> {
  private cache = new Map<K, V>();
  private maxSize: number;

  constructor(maxSize: number) {
    this.maxSize = maxSize;
  }

  get(key: K): V | undefined {
    const value = this.cache.get(key);
    if (value !== undefined) {
      // Move to end (most recently used)
      this.cache.delete(key);
      this.cache.set(key, value);
    }
    return value;
  }

  set(key: K, value: V): void {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.maxSize) {
      // Remove least recently used (first item)
      const firstKey = this.cache.keys().next().value;
      if (firstKey !== undefined) {
        this.cache.delete(firstKey);
      }
    }
    this.cache.set(key, value);
  }

  has(key: K): boolean {
    return this.cache.has(key);
  }

  clear(): void {
    this.cache.clear();
  }

  get size(): number {
    return this.cache.size;
  }
}

// Cache for parsed symbols per language - limited to 10 entries to prevent unbounded growth
const symbolCache = new LRUCache<string, Symbol[]>(10);
const runtimeCache = new Map<string, { parser: Parser; query: Parser.Query }>();
let parsersDir: string | null = null;
let queriesDir: string | null = null;

async function getParsersDir(): Promise<string> {
  if (!parsersDir) {
    parsersDir = path.join(os.homedir(), ".pi", "agent", "parsers");
    await fs.mkdir(parsersDir, { recursive: true });
  }
  return parsersDir;
}

async function getQueriesDir(): Promise<string> {
  if (!queriesDir) {
    queriesDir = path.join(os.homedir(), ".pi", "agent", "queries");
    await fs.mkdir(queriesDir, { recursive: true });
  }
  return queriesDir;
}

async function downloadFile(url: string, dest: string): Promise<boolean> {
  return new Promise((resolve) => {
    const file = createWriteStream(dest);
    https
      .get(url, (res) => {
        if (res.statusCode && res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
          downloadFile(res.headers.location, dest).then(resolve);
          return;
        }
        if (res.statusCode !== 200) {
          resolve(false);
          return;
        }
        res.pipe(file);
        file.on("finish", () => {
          file.close(() => resolve(true));
        });
      })
      .on("error", () => {
        fs.unlink(dest).catch(() => {});
        resolve(false);
      });
  });
}

async function ensureParser(config: ParserConfig): Promise<string | null> {
  if (config.localPath) {
    try {
      await fs.access(config.localPath);
      return config.localPath;
    } catch {
      // local path doesn't exist, continue
    }
  }

  if (!config.url) {
    return null;
  }

  const parsersDir = await getParsersDir();
  const fileName = `${config.language}.wasm`;
  const destPath = path.join(parsersDir, fileName);

  try {
    await fs.access(destPath);
    return destPath;
  } catch {
    // doesn't exist, download it
  }

  const success = await downloadFile(config.url, destPath);
  return success ? destPath : null;
}

async function walkDir(dir: string, extensions: string[], files: string[] = []): Promise<string[]> {
  try {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (entry.name === "node_modules" || entry.name === ".git" || entry.name.startsWith(".")) {
          continue;
        }
        await walkDir(fullPath, extensions, files);
      } else if (entry.isFile()) {
        const ext = path.extname(entry.name);
        if (extensions.includes(ext)) {
          files.push(fullPath);
        }
      }
    }
  } catch (err) {
    console.error("[pi-ckers] Error walking directory:", err);
  }
  return files;
}

async function findFiles(cwd: string, extensions: string[]): Promise<string[]> {
  return walkDir(cwd, extensions);
}

async function readQueryFile(filePath: string): Promise<string | null> {
  try {
    return await fs.readFile(filePath, "utf8");
  } catch {
    return null;
  }
}

/** Check if a path is a directory */
async function isDirectory(filePath: string): Promise<boolean> {
  try {
    const stat = await fs.stat(filePath);
    return stat.isDirectory();
  } catch {
    return false;
  }
}

/** Default discovery: looks for {language}.scm in search paths, then default dir */
async function defaultDiscoverQuery(
  language: string,
  searchPaths: string[],
  defaultDir: string
): Promise<string | null> {
  // Search custom paths first (priority order)
  for (const searchPath of searchPaths) {
    const isDir = await isDirectory(searchPath);
    const queryFile = isDir
      ? path.join(searchPath, `${language}.scm`)
      : searchPath;
    const content = await readQueryFile(queryFile);
    if (content) return content;
  }

  // Fallback to default queries dir
  const queryFile = path.join(defaultDir, `${language}.scm`);
  return readQueryFile(queryFile);
}

async function loadQuery(
  language: string,
  queriesDirs: string[] | QueryDiscovery | undefined
): Promise<string | null> {
  const defaultDir = await getQueriesDir();

  // If it's a function, use it as custom discovery
  if (typeof queriesDirs === "function") {
    return queriesDirs({
      language,
      defaultDir,
      readFile: readQueryFile,
    });
  }

  // Otherwise use default discovery with array of paths
  return defaultDiscoverQuery(language, queriesDirs ?? [], defaultDir);
}

async function parseFileWithTreesitter(
  filePath: string,
  runtime: { parser: Parser; query: Parser.Query },
): Promise<Symbol[]> {
  const symbols: Symbol[] = [];

  try {
    const sourceCode = await fs.readFile(filePath, "utf8");
    const tree = runtime.parser.parse(sourceCode);
    const matches = runtime.query.matches(tree.rootNode);

    for (const match of matches) {
      for (const capture of match.captures) {
        const node = capture.node;
        const captureName = capture.name;

        symbols.push({
          name: node.text,
          kind: captureName,
          file: filePath,
          line: node.startPosition.row + 1,
          column: node.startPosition.column,
        });
      }
    }
  } catch (err) {
    // If tree-sitter fails, return empty
    console.error(`[pi-ckers] Error parsing file ${filePath}:`, err);
  }

  return symbols;
}

async function parseWorkspace(
  config: ParserConfig,
  cwd: string,
  maxFiles: number,
  notify: (msg: string, type: "info" | "error") => void,
  queriesDirs: string[] | QueryDiscovery | undefined
): Promise<Symbol[]> {
  const cacheKey = `${config.language}:${cwd}`;
  if (symbolCache.has(cacheKey)) {
    return symbolCache.get(cacheKey)!;
  }

  // Load query file - required
  const queryText = await loadQuery(config.language, queriesDirs);
  if (!queryText) {
    // No query file, no symbols
    return [];
  }

  // Ensure parser is available
  const parserPath = await ensureParser(config);
  if (!parserPath) {
    notify(`Tree-sitter parser not available for ${config.language}`, "error");
    return [];
  }

  const files = await findFiles(cwd, config.extensions);
  const allSymbols: Symbol[] = [];

  let runtime = runtimeCache.get(config.language);
  if (!runtime) {
    const parser = new Parser();
    const loadedLanguage = await Parser.Language.load(parserPath);
    parser.setLanguage(loadedLanguage);
    runtime = {
      parser,
      query: loadedLanguage.query(queryText),
    };
    runtimeCache.set(config.language, runtime);
  }

  for (const file of files.slice(0, maxFiles)) {
    const symbols = await parseFileWithTreesitter(file, runtime);
    allSymbols.push(...symbols);
  }

  symbolCache.set(cacheKey, allSymbols);
  return allSymbols;
}

function filterSymbols(symbols: Symbol[], query: string): Symbol[] {
  const lowerQuery = query.toLowerCase();
  return symbols
    .filter((s) => s.name.toLowerCase().includes(lowerQuery))
    .slice(0, 20);
}

function formatSymbolValue(symbol: Symbol, isQuotedPrefix: boolean): string {
  const fileName = path.basename(symbol.file);
  const location = `${fileName}:${symbol.line}`;
  const value = `${symbol.name} (${location})`;

  if (!isQuotedPrefix && !value.includes(" ")) {
    return `@ts:${value}`;
  }
  return `@ts:"${value}"`;
}

export interface QueryDiscoveryContext {
  /** Language identifier (e.g., "typescript") */
  language: string;
  /** Default fallback directory (~/.pi/agent/queries) */
  defaultDir: string;
  /** Read file helper - returns null if not found */
  readFile: (filePath: string) => Promise<string | null>;
}

/** Custom function to discover query files. Return the query text or null. */
export type QueryDiscovery = (ctx: QueryDiscoveryContext) => Promise<string | null>;

export interface TreesitterPickerOptions {
  /** Parser configurations for different languages */
  parsers: ParserConfig[];
  /** Maximum number of files to scan per language (default: 100) */
  maxFiles?: number;
  /** Refresh interval in milliseconds (default: 60000) */
  refreshInterval?: number;
  /** Directories or files to search for query files, or a function that returns them.
   *
   *  - string[]: Array of directories or file paths to search. For directories,
   *    looks for {language}.scm. For files, reads them directly.
   *  - function: Custom discovery that returns the query text directly.
   *
   *  Falls back to ~/.pi/agent/queries/{language}.scm if not found.
   */
  queriesDirs?: string[] | QueryDiscovery;
}

/**
 * Create a treesitter workspace symbols picker for @ts: completions.
 *
 * Query files are loaded from ~/.pi/agent/queries/{language}.scm by default.
 *
 * Use queriesDirs to customize:
 * - string[]: Directories or specific files to search
 * - function: Custom discovery logic returning query text directly
 *
 * Parsers are downloaded on-demand to ~/.pi/agent/parsers/
 *
 * @example
 * ```typescript
 * import { tsWorkspaceSymbolsPicker } from "@elianiva/pi-ckers/builtin/treesitter";
 * import path from "node:path";
 *
 * // Simple: Custom directories (looks for {language}.scm in each)
 * const picker = tsWorkspaceSymbolsPicker({
 *   parsers: [...],
 *   queriesDirs: ["/home/user/.config/nvim/queries"]
 * });
 *
 * // Advanced: Custom discovery for nvim-treesitter structure
 * const nvimPicker = tsWorkspaceSymbolsPicker({
 *   parsers: [...],
 *   queriesDirs: async ({ language, defaultDir, readFile }) => {
 *     // Look for locals.scm in nvim-treesitter structure
 *     const nvimPath = path.join(
 *       "/Users/elianiva/.local/share/nvim/lazy/nvim-treesitter/queries",
 *       language,
 *       "locals.scm"
 *     );
 *     const content = await readFile(nvimPath);
 *     if (content) return content;
 *
 *     // Fallback to default
 *     return readFile(path.join(defaultDir, `${language}.scm`));
 *   }
 * });
 * ```
 */
export const tsWorkspaceSymbolsPicker = (options: TreesitterPickerOptions) => {
  const maxFiles = options.maxFiles ?? 100;
  const refreshInterval = options.refreshInterval ?? 60000;
  const queriesDirs = options.queriesDirs;
  let refreshTimer: ReturnType<typeof setInterval> | null = null;
  let notify: (msg: string, type: "info" | "error") => void = console.error;
  let currentCwd: string = "";

  return createPicker({
    type: "sync",
    prefix: "@ts:",
    minQueryLength: 1,

    init: async (ctx) => {
      currentCwd = ctx.cwd;
      notify = ctx.ui.notify.bind(ctx.ui);

      await getQueriesDir();
      await getParsersDir();

      for (const config of options.parsers) {
        await parseWorkspace(config, ctx.cwd, maxFiles, notify, queriesDirs);
      }

      if (refreshTimer) {
        clearInterval(refreshTimer);
      }
      refreshTimer = setInterval(async () => {
        if (!currentCwd) return;
        symbolCache.clear();
        for (const config of options.parsers) {
          await parseWorkspace(config, currentCwd, maxFiles, notify, queriesDirs);
        }
      }, refreshInterval);
    },

    search: (query: string, ctx: PickerContext) => {
      const allSymbols: Symbol[] = [];

      for (const config of options.parsers) {
        const cacheKey = `${config.language}:${ctx.cwd}`;
        const symbols = symbolCache.get(cacheKey);
        if (symbols) {
          allSymbols.push(...symbols);
        }
      }

      if (allSymbols.length === 0) {
        return null;
      }

      const filtered = filterSymbols(allSymbols, query);
      if (filtered.length === 0) {
        return null;
      }

      return filtered.map((symbol) => {
        const fileName = path.basename(symbol.file);
        return {
          value: formatSymbolValue(symbol, ctx.isQuotedPrefix),
          label: symbol.name,
          description: `${symbol.kind} · ${fileName}:${symbol.line}`,
        };
      });
    },

    clearCache: () => {
      symbolCache.clear();
      runtimeCache.clear();
    },

    destroy: () => {
      symbolCache.clear();
      runtimeCache.clear();
      if (refreshTimer) {
        clearInterval(refreshTimer);
        refreshTimer = null;
      }
      currentCwd = "";
    },
  });
};
