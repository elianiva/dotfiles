/**
 * pi:// protocol handler.
 *
 * Resolves pi:// URLs to documentation bundled with the pi package.
 *
 * URL forms:
 *   pi://             → list available docs
 *   pi://README.md    → pi's README
 *   pi://docs/xxx     → file from pi's docs/ directory
 *   pi://examples/xxx → file from pi's examples/ directory
 */
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";
import { getReadmePath, getDocsPath, getExamplesPath } from "@earendil-works/pi-coding-agent";
import { parseReadSelector } from "../utils/utils";

export interface PiDocResult {
  content: string;
  contentType: "text/markdown" | "text/plain";
  source: string;
}

const PI_PKG_DIR = join(getReadmePath(), "..");

/** Served prefixes and their filesystem roots. */
const MOUNTS: Array<{ prefix: string; root: string }> = [
  { prefix: "docs", root: getDocsPath() },
  { prefix: "examples", root: getExamplesPath() },
];

/** Files served at the root level. */
const ROOT_FILES: Array<{ name: string; label: string; path: string }> = [
  { name: "README.md", label: "README.md", path: getReadmePath() },
  { name: "CHANGELOG.md", label: "CHANGELOG.md", path: join(PI_PKG_DIR, "CHANGELOG.md") },
];

export async function resolvePiDoc(url: string): Promise<PiDocResult> {
  const parsed = parsePiUrl(url);

  if (!parsed.path) {
    return { content: renderIndex(), contentType: "text/markdown", source: "pi://" };
  }

  // Root files
  for (const rf of ROOT_FILES) {
    if (parsed.path === rf.name || parsed.path === rf.label) {
      return readFile(rf.path, `pi://${rf.label}`);
    }
  }

  // Mounted prefixes
  for (const mnt of MOUNTS) {
    const prefix = mnt.prefix + "/";
    if (parsed.path.startsWith(prefix) || parsed.path === mnt.prefix) {
      const relPath = parsed.path === mnt.prefix ? "" : parsed.path.slice(prefix.length);
      if (!relPath) {
        return { content: renderDirListing(mnt.root, mnt.prefix), contentType: "text/markdown", source: `pi://${mnt.prefix}/` };
      }
      const absPath = join(mnt.root, relPath);
      return readFile(absPath, `pi://${parsed.path}`);
    }
  }

  throw new Error(`pi:// file not found: "${parsed.path}". Use pi:// to list available files.`);
}

function parsePiUrl(raw: string): { path: string } {
  const m = raw.match(/^pi:\/\/(.*)$/);
  if (!m) return { path: "" };
  return { path: m[1] || "" };
}

export function isPiUrl(path: string): boolean {
  return /^pi:\/\//i.test(path);
}

function readFile(absPath: string, displayPath: string): PiDocResult {
  try {
    const s = statSync(absPath);
    if (s.isDirectory()) {
      const prefix = displayPath.replace(/^pi:\/\//, "");
      return { content: renderDirListing(absPath, prefix || undefined), contentType: "text/markdown", source: displayPath };
    }
    const content = readFileSync(absPath, "utf-8");
    const ext = absPath.toLowerCase();
    const contentType = ext.endsWith(".md") ? "text/markdown" : "text/plain";
    return { content, contentType, source: displayPath };
  } catch (err: any) {
    throw new Error(`pi:// file not found: "${displayPath}" (${err.message})`);
  }
}

function renderIndex(): string {
  const lines: string[] = ["# pi Documentation\n"];
  lines.push("## Root files\n");
  for (const rf of ROOT_FILES) {
    lines.push(`- [${rf.label}](pi://${rf.name})`);
  }
  for (const mnt of MOUNTS) {
    lines.push(`\n## ${mnt.prefix}/\n`);
    const items = listFiles(mnt.root);
    for (const item of items) {
      lines.push(`- [${item}](pi://${mnt.prefix}/${item})`);
    }
  }
  return lines.join("\n");
}

function renderDirListing(dir: string, prefix?: string): string {
  const items = listFiles(dir);
  const heading = prefix ? `# pi://${prefix}/\n` : "# Directory\n";
  return heading + "\n" + items.map((f) => `- [${f}](pi://${prefix ? prefix + "/" : ""}${f})`).join("\n");
}

function listFiles(dir: string): string[] {
  try {
    const entries = readdirSync(dir);
    return entries
      .filter((e) => {
        try { return statSync(join(dir, e)).isFile(); } catch { return false; }
      })
      .sort();
  } catch {
    return [];
  }
}

import type { ProtocolHandler } from "./types";

/** Protocol handler for pi:// URLs. */
export const piDocHandler: ProtocolHandler = {
  scheme: "pi",
  matches: isPiUrl,
  async resolve(path) {
    const { basePath } = parseReadSelector(path);
    const resolved = await resolvePiDoc(basePath);
    return {
      content: [{ type: "text", text: resolved.content }],
      details: { source: resolved.source, contentType: resolved.contentType },
    };
  },
};
