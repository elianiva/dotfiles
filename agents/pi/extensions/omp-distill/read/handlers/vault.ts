/**
 * vault:// protocol handler.
 *
 * Reads files from an Obsidian vault with QMD-powered search.
 * Supports .qmd (Quarto Markdown) files by stripping YAML frontmatter.
 *
 * URI forms:
 *   vault://path/to/file.md         → Read a file from the vault
 *   vault://path/to/file.qmd        → Read a .qmd file (strips YAML frontmatter)
 *   vault://                        → List vault root directory
 *   vault://subdir/                 → List a subdirectory
 *   vault://search?q=<query>        → Search vault using QMD
 *   vault://search?q=<query>&limit=N&collection=name
 *   vault://collections             → List QMD collections
 *   vault://tree                    → Full vault tree (recursive)
 *
 * Environment:
 *   PI_VAULT_DIR — path to Obsidian vault (default: ~/Development/personal/notes)
 *
 * Selectors via :raw, :N, :N-M, :N+K are supported on file reads.
 */
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve, relative, isAbsolute, sep } from "node:path";
import { homedir } from "node:os";
import { execSync } from "node:child_process";
import type { ProtocolHandler } from "./types";
import { parseReadSelector } from "../selector";

// ── Config ───────────────────────────────────────────────────────────

function getVaultDir(): string {
  return process.env.PI_VAULT_DIR || join(homedir(), "Development", "personal", "notes");
}

// ── YAML Frontmatter Parsing ─────────────────────────────────────────

interface ParsedQmd {
  frontmatter: Record<string, unknown>;
  body: string;
}

/**
 * Parse a .qmd (Quarto Markdown) file.
 * Strips YAML frontmatter (---\n...\n---\n) and returns both parts.
 */
function parseQmd(content: string): ParsedQmd | null {
  // Must start with ---
  if (!content.startsWith("---\n") && !content.startsWith("---\r\n")) {
    return null;
  }

  const lines = content.split(/\r?\n/);
  let endIdx = -1;

  // Find closing --- (line 1 onwards)
  for (let i = 1; i < lines.length; i++) {
    if (lines[i].trim() === "---") {
      endIdx = i;
      break;
    }
  }

  if (endIdx === -1) return null;

  const yamlBlock = lines.slice(1, endIdx).join("\n");
  const body = lines.slice(endIdx + 1).join("\n").trim();

  return {
    frontmatter: parseSimpleYaml(yamlBlock),
    body,
  };
}

/**
 * Minimal YAML key-value parser for Obsidian/Quarto frontmatter.
 * Handles simple values, arrays, and nested keys.
 */
function parseSimpleYaml(yaml: string): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  const lines = yaml.split("\n");

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;

    const colonIdx = trimmed.indexOf(":");
    if (colonIdx === -1) continue;

    const key = trimmed.slice(0, colonIdx).trim();
    let value: unknown = trimmed.slice(colonIdx + 1).trim();

    // Array: [item1, item2, ...]
    if (typeof value === "string" && value.startsWith("[") && value.endsWith("]")) {
      value = value.slice(1, -1).split(",").map((v) => v.trim().replace(/^["']|["']$/g, "")).filter(Boolean);
    } else if (typeof value === "string" && (value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    } else if (value === "" || value === "null" || value === "~") {
      value = null;
    } else if (value === "true") {
      value = true;
    } else if (value === "false") {
      value = false;
    } else if (/^\d+$/.test(String(value))) {
      value = parseInt(String(value), 10);
    } else if (/^\d+\.\d+$/.test(String(value))) {
      value = parseFloat(String(value));
    }

    result[key] = value;
  }

  return result;
}

// ── QMD Integration ──────────────────────────────────────────────────

/**
 * Shell out to qmd CLI for search.
 * Returns the JSON output parsed, or null if qmd isn't available.
 */
function qmdSearch(query: string, options: { limit?: number; collection?: string; minScore?: number }): unknown[] | null {
  try {
    const args = ["query", "--json"];
    if (options.limit) args.push("-n", String(options.limit));
    if (options.collection) args.push("-c", options.collection);
    if (options.minScore !== undefined) args.push("--min-score", String(options.minScore));
    args.push(query);

    const out = execSync(`qmd ${args.join(" ")}`, {
      encoding: "utf-8",
      timeout: 30_000,
      windowsHide: true,
    });

    return JSON.parse(out.trim()) as unknown[];
  } catch {
    return null;
  }
}

function isQmdAvailable(): boolean {
  try {
    execSync("qmd --version", { encoding: "utf-8", timeout: 5_000, windowsHide: true });
    return true;
  } catch {
    return false;
  }
}

/**
 * Try to get QMD collections list.
 */
function qmdCollections(): string | null {
  try {
    const out = execSync("qmd collection list --json", {
      encoding: "utf-8",
      timeout: 10_000,
      windowsHide: true,
    });
    return out.trim();
  } catch {
    return null;
  }
}

// ── Vault File Reading ───────────────────────────────────────────────

interface VaultFileResult {
  content: string;
  source: string;
  isQmd: boolean;
  frontmatter?: Record<string, unknown>;
}

function readVaultFile(vaultDir: string, relPath: string): VaultFileResult {
  const absPath = resolve(vaultDir, relPath);

  if (!statSync(absPath).isFile()) {
    throw new Error(`Not a file: ${relPath}`);
  }

  const content = readFileSync(absPath, "utf-8");
  const isQmd = relPath.toLowerCase().endsWith(".qmd");

  if (isQmd) {
    const parsed = parseQmd(content);
    if (parsed) {
      const meta = parsed.frontmatter;
      const metaLines = Object.entries(meta)
        .filter(([, v]) => v !== null && v !== undefined)
        .map(([k, v]) => `  ${k}: ${Array.isArray(v) ? v.join(", ") : String(v)}`);

      const formatted = [
        `# ${relPath} (QMD)`,
        "",
        "## Frontmatter",
        ...metaLines,
        "",
        "## Content",
        "",
        parsed.body,
      ].join("\n");

      return { content: formatted, source: `vault://${relPath}`, isQmd: true, frontmatter: meta };
    }
  }

  return { content, source: `vault://${relPath}`, isQmd };
}

// ── Directory Listing ────────────────────────────────────────────────

function formatDirListing(vaultDir: string, relPath: string): string {
  const absPath = resolve(vaultDir, relPath);
  const entries = readdirSync(absPath, { withFileTypes: true });

  const files: string[] = [];
  const dirs: string[] = [];

  for (const entry of entries) {
    const name = entry.name;
    if (name.startsWith(".")) continue; // skip hidden
    if (entry.isDirectory()) {
      dirs.push(name);
    } else if (entry.isFile()) {
      files.push(name);
    }
  }

  const lines: string[] = [];
  const prefix = relPath ? `vault://${relPath}/` : "vault://";
  const title = relPath ? `# vault://${relPath}/` : "# vault:// (Obsidian Vault)";

  lines.push(title);
  lines.push(`**Vault path:** \`${vaultDir}\``);
  lines.push("");

  if (dirs.length > 0) {
    lines.push("## Directories");
    for (const d of dirs) {
      lines.push(`- [${d}/](${prefix}${d}/)`);
    }
    lines.push("");
  }

  if (files.length > 0) {
    lines.push("## Files");
    for (const f of files) {
      lines.push(`- [${f}](${prefix}${f})`);
    }
    lines.push("");
  }

  lines.push("---");
  lines.push("*Use `vault://search?q=<query>` to search, `vault://collections` for QMD collections.*");

  return lines.join("\n");
}

function formatTree(vaultDir: string, relPath: string, depth = 0, maxDepth = 4): string {
  if (depth > maxDepth) return "";

  const absPath = resolve(vaultDir, relPath);
  const entries = readdirSync(absPath, { withFileTypes: true }).filter((e) => !e.name.startsWith("."));

  const lines: string[] = [];
  const indent = "  ".repeat(depth);

  for (const entry of entries) {
    const name = entry.name;
    const childRel = relPath ? `${relPath}/${name}` : name;

    if (entry.isDirectory()) {
      lines.push(`${indent}- **${name}/**`);
      const subtree = formatTree(vaultDir, childRel, depth + 1, maxDepth);
      if (subtree) lines.push(subtree);
    } else if (entry.isFile()) {
      const isQmd = name.toLowerCase().endsWith(".qmd");
      const icon = isQmd ? "📐" : "📄";
      lines.push(`${indent}- ${icon} [${name}](vault://${childRel})`);
    }
  }

  return lines.join("\n");
}

// ── Search Result Formatting ─────────────────────────────────────────

function formatQmdSearchResults(results: unknown[], query: string): string {
  const lines: string[] = [
    `# vault://search?q=${query}`,
    "",
    `**${results.length} result${results.length === 1 ? "" : "s"}**`,
    "",
  ];

  for (const r of results) {
    const result = r as Record<string, unknown>;
    const file = result.file || result.path || "(unknown)";
    const title = result.title || file;
    const score = result.score !== undefined ? ` (${Math.round(Number(result.score) * 100)}%)` : "";
    const snippet = result.snippet || result.excerpt || "";

    lines.push(`### ${title}${score}`);
    lines.push("");
    lines.push(`**Path:** \`${file}\``);
    if (snippet) {
      lines.push("");
      lines.push(snippet as string);
    }
    lines.push("");
    lines.push(`[View full note](vault://${file})`);
    lines.push("");
  }

  return lines.join("\n");
}

// ── URI Handling ─────────────────────────────────────────────────────

function classifyVaultUri(uri: string): {
  type: "search" | "collections" | "tree" | "doc" | "dir" | "root";
  path: string;
  searchParams: URLSearchParams;
} {
  const rest = uri.slice("vault://".length);

  // Search: vault://search?q=...
  if (rest.startsWith("search")) {
    const qsIdx = rest.indexOf("?");
    const qs = qsIdx >= 0 ? rest.slice(qsIdx + 1) : "";
    return { type: "search", path: "", searchParams: new URLSearchParams(qs) };
  }

  // Collections: vault://collections
  if (rest === "collections") {
    return { type: "collections", path: "", searchParams: new URLSearchParams() };
  }

  // Tree: vault://tree
  if (rest === "tree" || rest === "tree/") {
    return { type: "tree", path: "", searchParams: new URLSearchParams() };
  }

  // Dir: vault://path/to/dir/ or vault://path/to/dir (trailing slash = dir)
  const stripped = rest.replace(/\/+$/, "");
  if (stripped === "" || rest.endsWith("/")) {
    return { type: "dir", path: stripped, searchParams: new URLSearchParams() };
  }

  // Check if path is a directory
  const vaultDir = getVaultDir();
  const absPath = resolve(vaultDir, stripped);
  try {
    if (statSync(absPath).isDirectory()) {
      return { type: "dir", path: stripped, searchParams: new URLSearchParams() };
    }
  } catch {
    // not found or can't stat
  }

  // Doc: vault://path/to/file
  return { type: "doc", path: stripped, searchParams: new URLSearchParams() };
}

// ── Handler Export ───────────────────────────────────────────────────

export function isVaultUrl(path: string): boolean {
  return /^vault:\/\//i.test(path);
}

/**
 * Format a "how to set up QMD" message.
 */
function qmdSetupGuide(context: string = "search"): string {
  const vaultDir = getVaultDir();
  const hint = context === "search"
    ? "Then try `vault://search?q=<query>` again."
    : "Then try again.";
  return [
    `# vault://${context} — QMD not configured`,
    "",
    "To search your vault with QMD, set it up first:",
    "",
    "```bash",
    `# Add your vault as a QMD collection`,
    `qmd collection add "${vaultDir}" --name vault`,
    "",
    `# Add context for better search results`,
    `qmd context add qmd://vault "Personal notes vault"`,
    "",
    `# Generate embeddings`,
    `qmd embed`,
    "```",
    "",
    hint,
  ].join("\n");
}

export const vaultHandler: ProtocolHandler = {
  scheme: "vault",
  matches: isVaultUrl,

  async resolve(rawPath, ctx) {
    const vaultDir = getVaultDir();
    const { basePath, raw, offset, limit } = parseReadSelector(rawPath);
    const classification = classifyVaultUri(basePath);

    switch (classification.type) {
      case "search": {
        const query = classification.searchParams.get("q") || classification.searchParams.get("query") || "";
        if (!query) {
          return {
            content: [{ type: "text", text: "Usage: vault://search?q=<query>[&limit=N][&collection=name]" }],
            details: { source: "vault://search" },
            isError: true,
          };
        }

        if (!isQmdAvailable()) {
          return {
            content: [{ type: "text", text: qmdSetupGuide("search") }],
            details: { source: "vault://search" },
            isError: true,
          };
        }

        const limit = parseInt(classification.searchParams.get("limit") || "10", 10);
        const collection = classification.searchParams.get("collection") || undefined;
        const minScore = parseFloat(classification.searchParams.get("minScore") || "0");

        const results = qmdSearch(query, { limit, collection, minScore });
        if (!results || results.length === 0) {
          return {
            content: [{ type: "text", text: `# vault://search\n\nNo results for query: "${query}"` }],
            details: { source: "vault://search", query },
          };
        }

        return {
          content: [{ type: "text", text: formatQmdSearchResults(results, query) }],
          details: { source: "vault://search", query, count: results.length },
        };
      }

      case "collections": {
        if (!isQmdAvailable()) {
          return {
            content: [{ type: "text", text: qmdSetupGuide("collections") }],
            details: { source: "vault://collections" },
            isError: true,
          };
        }

        const out = qmdCollections();
        if (!out) {
          return {
            content: [{ type: "text", text: "# vault://collections\n\nNo QMD collections configured." }],
            details: { source: "vault://collections" },
          };
        }

        return {
          content: [{ type: "text", text: `# vault://collections\n\n\`\`\`json\n${out}\n\`\`\`` }],
          details: { source: "vault://collections" },
        };
      }

      case "tree": {
        try {
          const tree = formatTree(vaultDir, "");
          return {
            content: [{ type: "text", text: `# vault://tree\n\n**Vault:** \`${vaultDir}\`\n\n${tree}` }],
            details: { source: "vault://tree" },
          };
        } catch (err: any) {
          return {
            content: [{ type: "text", text: `Error reading vault: ${err.message}` }],
            details: { source: "vault://tree" },
            isError: true,
          };
        }
      }

      case "dir": {
        try {
          const listing = formatDirListing(vaultDir, classification.path);
          return {
            content: [{ type: "text", text: listing }],
            details: { source: `vault://${classification.path}/`, vaultDir },
          };
        } catch (err: any) {
          return {
            content: [{ type: "text", text: `Error reading directory "${classification.path}": ${err.message}` }],
            details: { source: "vault://" },
            isError: true,
          };
        }
      }

      case "doc": {
        try {
          const result = readVaultFile(vaultDir, classification.path);
          let output = result.content;

          // Apply selectors
          if (!raw) {
            const bodyLines = output.split("\n");
            if (offset !== undefined) {
              const start = Math.max(0, offset - 1);
              const end = limit !== undefined ? start + limit : bodyLines.length;
              output = bodyLines.slice(start, end).join("\n");
              if (end < bodyLines.length) {
                output += `\n\n[${bodyLines.length - end} more lines. Use offset=${end + 1} to continue]`;
              }
            }
            if (limit !== undefined && offset === undefined) {
              output = bodyLines.slice(0, limit).join("\n");
              if (limit < bodyLines.length) {
                output += `\n\n[${bodyLines.length - limit} more lines. Use offset=${limit + 1} to continue]`;
              }
            }
          }

          const details: Record<string, unknown> = { source: result.source };
          if (result.isQmd) details.isQmd = true;
          if (result.frontmatter) details.frontmatter = result.frontmatter;

          return {
            content: [{ type: "text", text: output }],
            details,
          };
        } catch (err: any) {
          return {
            content: [{ type: "text", text: `vault://${classification.path}: ${err.message}` }],
            details: { source: `vault://${classification.path}` },
            isError: true,
          };
        }
      }

      default:
        return {
          content: [{ type: "text", text: "Invalid vault:// URI." }],
          details: {},
          isError: true,
        };
    }
  },
};
