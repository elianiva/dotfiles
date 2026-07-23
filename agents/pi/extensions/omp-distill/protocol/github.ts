/**
 * issue:// and pr:// protocol handlers.
 *
 * Resolves GitHub issues and pull requests via the `gh` CLI.
 * Requires `gh` to be installed and authenticated.
 *
 * URL forms:
 *   issue://<number>           → single issue in the current repo
 *   issue://<owner>/<repo>/<n> → fully qualified issue
 *   pr://<number>              → single PR in the current repo
 *   pr://<owner>/<repo>/<n>    → fully qualified PR
 */
import { parseReadSelector } from "../utils/utils";
import type { ProtocolHandler } from "./types";
import { execGhSync } from "./gh-utils";

export interface GhResult {
  content: string;
  source: string;
  notes?: string[];
}

/**
 * Resolve an issue:// URL.
 */
export async function resolveIssue(raw: string, cwd: string): Promise<GhResult> {
  const parsed = parseIssuePrUrl(raw, "issue");
  if (!parsed) {
    throw new Error("Invalid issue:// URL. Usage: issue://<number> or issue://<owner>/<repo>/<number>");
  }
  return fetchGhItem("issue", parsed, cwd);
}

/**
 * Resolve a pr:// URL.
 */
export async function resolvePr(raw: string, cwd: string): Promise<GhResult> {
  const parsed = parseIssuePrUrl(raw, "pr");
  if (!parsed) {
    throw new Error("Invalid pr:// URL. Usage: pr://<number> or pr://<owner>/<repo>/<number>");
  }
  return fetchGhItem("pr", parsed, cwd);
}

export function isIssueUrl(path: string): boolean {
  return /^issue:\/\//i.test(path);
}

export function isPrUrl(path: string): boolean {
  return /^pr:\/\//i.test(path);
}

// --- Internal ---

interface ParsedIssuePr {
  number: number;
  repo?: string; // "owner/repo"
}

function parseIssuePrUrl(raw: string, kind: "issue" | "pr"): ParsedIssuePr | null {
  const scheme = `${kind}://`;
  const rest = raw.startsWith(scheme) ? raw.slice(scheme.length) : "";
  if (!rest) return null;

  const parts = rest.split("/").filter(Boolean);

  if (parts.length === 1) {
    // issue://123
    const n = parseInt(parts[0], 10);
    return isNaN(n) ? null : { number: n };
  }

  if (parts.length === 3) {
    // issue://owner/repo/123
    const n = parseInt(parts[2], 10);
    return isNaN(n) ? null : { number: n, repo: `${parts[0]}/${parts[1]}` };
  }

  return null;
}

function fetchGhItem(
  kind: "issue" | "pr",
  parsed: ParsedIssuePr,
  cwd: string,
): GhResult {
  const type = kind === "issue" ? "issue" : "pr";
  const repoFlag = parsed.repo ? ["--repo", parsed.repo] : [];

  const fields = [
    "number", "title", "state", "author", "body", "labels",
    "createdAt", "updatedAt", "url", "comments",
  ];
  const prExtra = kind === "pr"
    ? ["isDraft", "baseRefName", "headRefName", "additions", "deletions", "mergeable"]
    : [];

  const json = execGhSync(
    [type, "view", String(parsed.number), ...repoFlag, "--json", [...fields, ...prExtra].join(",")],
    { cwd },
  );

  const data = JSON.parse(json);
  return formatGhItem(kind, data, parsed.repo);
}

function formatGhItem(kind: "issue" | "pr", data: any, repo?: string): GhResult {
  const type = kind === "issue" ? "Issue" : "Pull Request";
  const number = data.number;
  const title = data.title ?? "(no title)";
  const state = data.state ?? "?";
  const author = data.author?.login ?? "?";
  const createdAt = data.createdAt ?? "";
  const updatedAt = data.updatedAt ?? "";
  const labels = (data.labels ?? []).map((l: any) => l.name).filter(Boolean).join(", ");
  const body = data.body?.trim() ?? "(no description)";
  const comments = data.comments ?? [];
  const repoPart = repo ? `${repo}` : "";

  const lines: string[] = [];

  lines.push(`# ${type} #${number}: ${title}`);
  lines.push("");
  lines.push(`**State:** ${state}  **Author:** @${author}  **Created:** ${createdAt.slice(0, 10)}  **Updated:** ${updatedAt.slice(0, 10)}`);
  if (labels) lines.push(`**Labels:** ${labels}`);

  if (kind === "pr") {
    const draft = data.isDraft ? " [DRAFT]" : "";
    lines.push(`**Base:** ${data.baseRefName} ← **Head:** ${data.headRefName}${draft}`);
    if (data.additions !== undefined && data.deletions !== undefined) {
      lines.push(`**Diff:** +${data.additions} / -${data.deletions}  **Mergeable:** ${data.mergeable ?? "unknown"}`);
    }
  }

  lines.push(`**URL:** ${data.url ?? ""}`);
  lines.push("");

  // Body
  if (body && body !== "(no description)") {
    lines.push("---");
    lines.push("");
    lines.push(body);
    lines.push("");
  }

  // Comments
  if (comments.length > 0) {
    lines.push("---");
    lines.push(`## Comments (${comments.length})`);
    lines.push("");
    for (const c of comments) {
      const ca = c.author?.login ?? "?";
      const cBody = c.body?.trim() ?? "";
      const cDate = c.createdAt?.slice(0, 10) ?? "";
      lines.push(`**@${ca}** — ${cDate}`);
      lines.push("");
      lines.push(cBody);
      lines.push("");
      lines.push("---");
      lines.push("");
    }
  }

  return {
    content: lines.join("\n"),
    source: `${type.toLowerCase()}://${repoPart}${repoPart ? "/" : ""}${number}`,
  };
}

/** Protocol handler for issue:// URLs. */
export const issueHandler: ProtocolHandler = {
  scheme: "issue",
  matches: isIssueUrl,
  async resolve(path, ctx) {
    const { basePath } = parseReadSelector(path);
    const resolved = await resolveIssue(basePath, ctx.cwd);
    return {
      content: [{ type: "text", text: resolved.content }],
      details: { source: resolved.source, notes: resolved.notes },
    };
  },
};

/** Protocol handler for pr:// URLs. */
export const prHandler: ProtocolHandler = {
  scheme: "pr",
  matches: isPrUrl,
  async resolve(path, ctx) {
    const { basePath } = parseReadSelector(path);
    const resolved = await resolvePr(basePath, ctx.cwd);
    return {
      content: [{ type: "text", text: resolved.content }],
      details: { source: resolved.source, notes: resolved.notes },
    };
  },
};


