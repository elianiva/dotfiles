/**
 * conflict:// protocol handler.
 *
 * Resolves conflict information for git and jj repos without needing
 * to shell out to VCS commands manually.
 *
 * URL forms:
 *   conflict://              — list all conflicted files
 *   conflict://<path>        — show conflict details for a specific file
 */
import { execSync } from "node:child_process";
import { readFileSync, statSync } from "node:fs";
import path from "node:path";
import type { ProtocolHandler } from "./types";
import { parseReadSelector } from "../utils/utils";

export interface ConflictResult {
  content: string;
  source: string;
}

type VcsKind = "git" | "jj" | null;

/** Detect VCS kind by walking up from cwd looking for .jj/ or .git/. */
function detectVcs(cwd: string): { kind: VcsKind; root: string } {
  let dir = path.resolve(cwd);
  // Walk up at most 10 levels to avoid infinite loops
  for (let i = 0; i < 10; i++) {
    try {
      if (statSync(path.join(dir, ".jj")).isDirectory()) {
        return { kind: "jj", root: dir };
      }
    } catch { /* not found */ }
    try {
      if (statSync(path.join(dir, ".git")).isDirectory()) {
        return { kind: "git", root: dir };
      }
    } catch { /* not found */ }
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return { kind: null, root: cwd };
}

function exec(cmd: string, cwd: string): string {
  return execSync(cmd, { encoding: "utf-8", cwd, timeout: 15_000 }).trim();
}

/** List conflicted files via git. */
function listGitConflicts(cwd: string): string[] {
  const out = exec("git diff --name-only --diff-filter=U", cwd);
  return out ? out.split("\n").filter(Boolean) : [];
}

/** List conflicted files via jj. */
function listJjConflicts(cwd: string): string[] {
  // Redirect stderr to avoid noise from "No conflicts" (exit code != 0)
  try {
    const out = execSync("jj resolve --list 2>/dev/null", { encoding: "utf-8", cwd, timeout: 15_000 }).trim();
    const files: string[] = [];
    for (const line of out.split("\n")) {
      const trimmed = line.trim();
      if (trimmed) {
        const colonIdx = trimmed.indexOf(": ");
        const file = colonIdx >= 0 ? trimmed.slice(0, colonIdx) : trimmed;
        files.push(file);
      }
    }
    return files;
  } catch {
    return [];
  }
  const files: string[] = [];
  for (const line of out.split("\n")) {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith("Error: No conflicts")) {
      // Lines look like: "path/to/file: description" or just "path/to/file"
      const colonIdx = trimmed.indexOf(": ");
      const file = colonIdx >= 0 ? trimmed.slice(0, colonIdx) : trimmed;
      files.push(file);
    }
  }
  return files;
}

/** Get git conflict details for a specific file. */
function gitFileConflict(file: string, cwd: string): string {
  const lines: string[] = [];
  const absPath = path.resolve(cwd, file);

  // Read the file with conflict markers
  try {
    const content = readFileSync(absPath, "utf-8");
    lines.push(`# Conflict: ${file}`);
    lines.push("");
    lines.push(content);
  } catch {
    lines.push(`File not found: ${file}`);
  }

  // Show ancestor, ours, theirs stages
  for (const [label, ref] of [["Ours (stage 2)", ":2:"], ["Theirs (stage 3)", ":3:"]] as const) {
    try {
      const stage = exec(`git show ${ref}${file}`, cwd);
      lines.push("");
      lines.push(`--- ${label} ---`);
      lines.push("");
      lines.push(stage);
    } catch {
      // Stage may not exist
    }
  }

  return lines.join("\n");
}

/** Get jj conflict details for a specific file. */
function jjFileConflict(file: string, cwd: string): string {
  const lines: string[] = [];
  const absPath = path.resolve(cwd, file);

  // Read the file with conflict markers
  try {
    const content = readFileSync(absPath, "utf-8");
    lines.push(`# Conflict: ${file} (jj)`);
    lines.push("");
    lines.push(content);
  } catch {
    lines.push(`File not found: ${file}`);
  }

  // Show jj file info for the conflicted revision
  try {
    const sides = exec(`jj file show ${file}`, cwd);
    if (sides) {
      lines.push("");
      lines.push("--- jj file show (working copy) ---");
      lines.push("");
      lines.push(sides);
    }
  } catch {
    // fallback — file content with markers is already shown above
  }

  return lines.join("\n");
}

/**
 * Resolve a conflict:// URL.
 */
export function resolveConflict(raw: string, cwd: string): ConflictResult {
  const { basePath } = parseReadSelector(raw);
  const file = basePath.slice("conflict://".length);

  const { kind, root } = detectVcs(cwd);
  if (!kind) {
    throw new Error("Not inside a git or jj repository — cannot resolve conflicts");
  }

  if (!file) {
    // List all conflicted files
    const files = kind === "git" ? listGitConflicts(root) : listJjConflicts(root);

    if (files.length === 0) {
      return {
        content: `No conflicts found (${kind} repo at ${root})`,
        source: "conflict://",
      };
    }

    const lines: string[] = [
      `# Conflicts (${files.length} file${files.length === 1 ? "" : "s"}) — ${kind}`,
      "",
      ...files.map((f, i) => `${i + 1}. \`${f}\``),
      "",
      "Use `conflict://<file>` to view details for a specific file.",
    ];
    return { content: lines.join("\n"), source: `conflict:// (${kind})` };
  }

  // Show details for a specific file
  const content = kind === "git"
    ? gitFileConflict(file, root)
    : jjFileConflict(file, root);
  return { content, source: `conflict://${file}` };
}

export function isConflictUrl(path: string): boolean {
  return /^conflict:\/\//i.test(path);
}

/** Protocol handler for conflict:// URLs. */
export const conflictHandler: ProtocolHandler = {
  scheme: "conflict",
  matches: isConflictUrl,
  resolve(path, ctx) {
    const resolved = resolveConflict(path, ctx.cwd);
    return Promise.resolve({
      content: [{ type: "text", text: resolved.content }],
      details: { source: resolved.source },
    });
  },
};
