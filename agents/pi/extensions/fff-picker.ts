import path from "node:path";
import os from "node:os";
import fs from "node:fs";
import https from "node:https";
import { fileURLToPath } from "node:url";
import koffi from "koffi";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { CombinedAutocompleteProvider, type AutocompleteItem } from "@mariozechner/pi-tui";

// --- Downloader logic ---
const FFF_URL = "https://github.com/dmtrKovalenko/fff.nvim/releases/download/7c2d46f/c-lib-aarch64-apple-darwin.dylib";

async function downloadFile(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (res) => {
      if (res.statusCode && res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        downloadFile(res.headers.location, dest).then(resolve, reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`Download failed: ${res.statusCode}`));
        return;
      }
      res.pipe(file);
      file.on("finish", () => file.close(() => resolve()));
    }).on("error", (err) => {
      fs.unlink(dest, () => reject(err));
    });
  });
}

async function ensureFffBinary(binDir: string): Promise<string> {
  await fs.promises.mkdir(binDir, { recursive: true });
  const target = path.join(binDir, "libfff.dylib");
  if (fs.existsSync(target)) return target;
  await downloadFile(FFF_URL, target);
  return target;
}

// --- Bindings types and structs ---
export type FffHandle = koffi.Pointer;

type Result<T> = { ok: true; value: T } | { ok: false; error: string };
type ResultWithHandle<T> =
  | { ok: true; value: T; handle?: FffHandle }
  | { ok: false; error: string };

interface SearchItem {
  path: string;
  relativePath: string;
  fileName: string;
  size: number;
  modified: number; // Unix timestamp
  accessFrecencyScore: number;
  modificationFrecencyScore: number;
  totalFrecencyScore: number;
  gitStatus: "modified" | "clean" | "untracked" | (string & {}); // Added string for extensibility
  isBinary: boolean;
}

interface Score {
  total: number;
  baseScore: number;
  filenameBonus: number;
  specialFilenameBonus: number;
  frecencyBoost: number;
  distancePenalty: number;
  currentFilePenalty: number;
  comboMatchBoost: number;
  exactMatch: boolean;
  matchType: "fuzzy_filename" | (string & {}); // Added string for extensibility
}

export interface FilePickerResponse {
  items: SearchItem[];
  scores: Score[];
}

const FffResult = koffi.struct("FffResult", {
  success: "bool",
  _pad0: koffi.array("uint8", 7),
  data: "void *",
  error: "void *",
  handle: "void *",
});

type FffParsedResult = {
  success: boolean;
  data: string | null;
  error: string | null;
  handle: FffHandle | null;
};

type LibraryHandle = {
  fff_create: (optsJson: string) => koffi.Pointer;
  fff_destroy: (handle: FffHandle) => void;
  fff_search: (
    handle: FffHandle,
    query: string,
    optsJson: string,
  ) => koffi.Pointer;
  fff_live_grep: (
    handle: FffHandle,
    query: string,
    optsJson: string,
  ) => koffi.Pointer;
  fff_scan_files: (handle: FffHandle) => koffi.Pointer;
  fff_is_scanning: (handle: FffHandle) => boolean;
  fff_get_scan_progress: (handle: FffHandle) => koffi.Pointer;
  fff_wait_for_scan: (handle: FffHandle, timeoutMs: number) => koffi.Pointer;
  fff_restart_index: (handle: FffHandle, newPath: string) => koffi.Pointer;
  fff_track_access: (handle: FffHandle, path: string) => koffi.Pointer;
  fff_refresh_git_status: (handle: FffHandle) => koffi.Pointer;
  fff_track_query: (
    handle: FffHandle,
    query: string,
    filePath: string,
  ) => koffi.Pointer;
  fff_get_historical_query: (handle: FffHandle, index: number) => koffi.Pointer;
  fff_health_check: (handle: FffHandle, payload: string) => koffi.Pointer;
  fff_free_result: (result: koffi.Pointer) => void;
  fff_free_string: (ptr: koffi.Pointer) => void;
};

function decodeCString(ptr: koffi.Pointer | null): string | null {
  if (!ptr) return null;
  return koffi.decode(ptr, "char", -1) as string;
}

function snakeToCamel(obj: unknown): unknown {
  if (obj === null || obj === undefined) return obj;
  if (typeof obj !== "object") return obj;
  if (Array.isArray(obj)) return obj.map(snakeToCamel);

  const result: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
    const camelKey = key.replace(/_([a-z])/g, (_, letter) =>
      letter.toUpperCase(),
    );
    result[camelKey] = snakeToCamel(value);
  }
  return result;
}

export class FffBindings {
  private lib: LibraryHandle;

  constructor(dylibPath: string) {
    const lib = koffi.load(dylibPath);

    this.lib = {
      fff_create: lib.func("void *fff_create(const char *opts_json)"),
      fff_destroy: lib.func("void fff_destroy(void *handle)"),
      fff_search: lib.func(
        "void *fff_search(void *handle, const char *query, const char *opts_json)",
      ),
      fff_live_grep: lib.func(
        "void *fff_live_grep(void *handle, const char *query, const char *opts_json)",
      ),
      fff_scan_files: lib.func("void *fff_scan_files(void *handle)"),
      fff_is_scanning: lib.func("bool fff_is_scanning(void *handle)"),
      fff_get_scan_progress: lib.func(
        "void *fff_get_scan_progress(void *handle)",
      ),
      fff_wait_for_scan: lib.func(
        "void *fff_wait_for_scan(void *handle, uint64_t timeout_ms)",
      ),
      fff_restart_index: lib.func(
        "void *fff_restart_index(void *handle, const char *new_path)",
      ),
      fff_track_access: lib.func(
        "void *fff_track_access(void *handle, const char *path)",
      ),
      fff_refresh_git_status: lib.func(
        "void *fff_refresh_git_status(void *handle)",
      ),
      fff_track_query: lib.func(
        "void *fff_track_query(void *handle, const char *query, const char *file_path)",
      ),
      fff_get_historical_query: lib.func(
        "void *fff_get_historical_query(void *handle, uint64_t index)",
      ),
      fff_health_check: lib.func(
        "void *fff_health_check(void *handle, const char *payload)",
      ),
      fff_free_result: lib.func("void fff_free_result(void *result)"),
      fff_free_string: lib.func("void fff_free_string(void *ptr)"),
    };
  }

  private readResult(resultPtr: koffi.Pointer): FffParsedResult {
    if (!resultPtr) {
      return {
        success: false,
        data: null,
        error: "Null result",
        handle: null,
      };
    }

    const raw = koffi.decode(resultPtr, FffResult) as {
      success: boolean;
      data: koffi.Pointer | null;
      error: koffi.Pointer | null;
      handle: koffi.Pointer | null;
    };

    return {
      success: Boolean(raw.success),
      data: decodeCString(raw.data),
      error: decodeCString(raw.error),
      handle: raw.handle ?? null,
    };
  }

  private withResult<T>(
    resultPtr: koffi.Pointer,
    map: (res: FffParsedResult) => T,
  ): T {
    const parsed = this.readResult(resultPtr);
    try {
      return map(parsed);
    } finally {
      if (resultPtr) this.lib.fff_free_result(resultPtr);
    }
  }

  private parseJson<T>(data: string | null): T {
    if (data === null || data === "") return undefined as T;
    try {
      const parsed = JSON.parse(data);
      return snakeToCamel(parsed) as T;
    } catch {
      return data as T;
    }
  }

  private parseResult<T>(resultPtr: koffi.Pointer): Result<T> {
    return this.withResult(resultPtr, (res) => {
      if (!res.success)
        return { ok: false, error: res.error ?? "Unknown error" };
      return { ok: true, value: this.parseJson<T>(res.data) };
    });
  }

  create(opts: Record<string, unknown>): ResultWithHandle<FffHandle> {
    return this.withResult(this.lib.fff_create(JSON.stringify(opts)), (res) => {
      if (!res.success)
        return { ok: false, error: res.error ?? "Unknown error" };
      if (!res.handle)
        return { ok: false, error: "fff_create returned null handle" };
      return { ok: true, value: res.handle, handle: res.handle };
    });
  }

  destroy(handle: FffHandle): void {
    this.lib.fff_destroy(handle);
  }

  search(handle: FffHandle, query: string, opts: Record<string, unknown>) {
    return this.parseResult<unknown[]>(
      this.lib.fff_search(handle, query, JSON.stringify(opts)),
    ) as Result<FilePickerResponse>;
  }

  scanFiles(handle: FffHandle) {
    return this.parseResult<void>(this.lib.fff_scan_files(handle));
  }

  liveGrep(handle: FffHandle, query: string, opts: Record<string, unknown>) {
    return this.parseResult<unknown[]>(
      this.lib.fff_live_grep(handle, query, JSON.stringify(opts)),
    );
  }

  isScanning(handle: FffHandle): boolean {
    return this.lib.fff_is_scanning(handle);
  }

  getScanProgress(handle: FffHandle) {
    return this.parseResult<Record<string, unknown>>(
      this.lib.fff_get_scan_progress(handle),
    );
  }

  waitForScan(handle: FffHandle, timeoutMs: number): Result<boolean> {
    const result = this.parseResult<boolean | string>(
      this.lib.fff_wait_for_scan(handle, timeoutMs),
    );
    if (!result.ok) return result;
    return {
      ok: true,
      value: result.value === true || result.value === "true",
    };
  }

  restartIndex(handle: FffHandle, newPath: string) {
    return this.parseResult<void>(this.lib.fff_restart_index(handle, newPath));
  }

  trackAccess(handle: FffHandle, filePath: string): Result<boolean> {
    const result = this.parseResult<boolean | string>(
      this.lib.fff_track_access(handle, filePath),
    );
    if (!result.ok) return result;
    return {
      ok: true,
      value: result.value === true || result.value === "true",
    };
  }

  refreshGitStatus(handle: FffHandle): Result<number> {
    const result = this.parseResult<number | string>(
      this.lib.fff_refresh_git_status(handle),
    );
    if (!result.ok) return result;
    return {
      ok: true,
      value:
        typeof result.value === "number"
          ? result.value
          : parseInt(result.value, 10),
    };
  }

  trackQuery(
    handle: FffHandle,
    query: string,
    filePath: string,
  ): Result<boolean> {
    const result = this.parseResult<boolean | string>(
      this.lib.fff_track_query(handle, query, filePath),
    );
    if (!result.ok) return result;
    return {
      ok: true,
      value: result.value === true || result.value === "true",
    };
  }

  getHistoricalQuery(handle: FffHandle, offset: number): Result<string | null> {
    const result = this.parseResult<string | null>(
      this.lib.fff_get_historical_query(handle, offset),
    );
    if (!result.ok) return result;
    if (result.value === null || result.value === "null") {
      return { ok: true, value: null };
    }
    return result as Result<string>;
  }

  healthCheck(handle: FffHandle, testPath: string) {
    return this.parseResult<Record<string, unknown>>(
      this.lib.fff_health_check(handle, testPath),
    );
  }
}

// --- Extension implementation ---

type FuzzyOptions = { isQuotedPrefix?: boolean };

type FuzzyGet = (query: string, options: FuzzyOptions) => AutocompleteItem[];

type CombinedAutocompleteProviderPatched = {
  getFuzzyFileSuggestions: FuzzyGet;
  __fffPatched?: boolean;
};

let fff: FffBindings | null = null;
let handle: FffHandle | null = null;

function normalizePath(p: string): string {
  return p.replace(/\\/g, "/").replace(/^\.\//, "").replace(/\/$/, "");
}

function buildCompletionValue(p: string, isQuotedPrefix: boolean): string {
  if (!isQuotedPrefix && !p.includes(" ")) {
    return `@${p}`;
  }
  return `@"${p}"`;
}

function searchFff(query: string, isQuotedPrefix: boolean, limit: number): AutocompleteItem[] {
  if (!fff || !handle) return [];

  const result = fff.search(handle, query, { pageSize: Math.max(limit, 20) });
  if (!result.ok) return [];

  return result.value.items.slice(0, limit).map((item) => {
    const isDirectory = item.relativePath.endsWith("/");
    const p = normalizePath(item.relativePath);
    return {
      value: buildCompletionValue(p, isQuotedPrefix),
      label: item.fileName + (isDirectory ? "/" : ""),
      description: p,
    };
  });
}

function patchFilePicker() {
  const prototype = CombinedAutocompleteProvider.prototype as unknown as CombinedAutocompleteProviderPatched;
  if (prototype.__fffPatched) return;

  const originalGet = prototype.getFuzzyFileSuggestions;

  prototype.getFuzzyFileSuggestions = function(this: any, query: string, options: FuzzyOptions): AutocompleteItem[] {
    const suggestions = searchFff(query, Boolean(options?.isQuotedPrefix), 20);
    if (suggestions.length > 0) {
      return suggestions;
    }

    return originalGet.call(this, query, options);
  };

  prototype.__fffPatched = true;
}

export default function fffPickerExtension(pi: ExtensionAPI) {
  let originalGet: FuzzyGet | null = null;

  pi.on("session_start", async (_ev, ctx) => {
    if (!ctx.hasUI) return;
    if (process.platform !== "darwin") return;
    if (process.arch !== "arm64") return;

    const binDir = path.join(
      path.dirname(fileURLToPath(import.meta.url)),
      "..",
      "bin",
    );
    const dylibPath = await ensureFffBinary(binDir);

    fff = new FffBindings(dylibPath);
    const created = fff.create({ base_path: ctx.cwd });
    if (created.ok && created.handle) {
      handle = created.handle;
      fff.scanFiles(handle);

      const prototype = CombinedAutocompleteProvider.prototype as any;
      if (!prototype.__fffPatched) {
          originalGet = prototype.getFuzzyFileSuggestions;
          patchFilePicker();
      }
    } else {
      ctx.ui.notify(
        `FFF init failed: ${created.ok ? "unknown" : created.error}`,
        "error",
      );
    }
  });

  pi.on("session_shutdown", () => {
    if (fff && handle) {
      fff.destroy(handle);
    }
    fff = null;
    handle = null;

    const prototype = CombinedAutocompleteProvider.prototype as any;
    if (prototype.__fffPatched && originalGet) {
        prototype.getFuzzyFileSuggestions = originalGet;
        delete prototype.__fffPatched;
    }
  });
}
