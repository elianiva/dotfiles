/**
 * GitHub repo cloning/extraction.
 *
 * Parses GitHub URLs, clones repos to ~/Development/repos, and
 * returns structured content (file tree, README, file contents).
 * Falls back to `gh` API when cloning is not forced or fails.
 * All fs operations use async APIs.
 */
import { promises as fs, constants as fsc } from "node:fs";
import { execFile } from "node:child_process";
import { extname, join, resolve as resolvePath, sep as pathSep } from "node:path";
import { homedir } from "node:os";
async function isProbablyBinary(filePath: string): Promise<boolean> {
  const fd = await fs.open(filePath);
  try {
    const { size } = await fd.stat();
    const len = Math.min(size, 8192);
    if (len === 0) return false;
    const buf = Buffer.allocUnsafe(len);
    const { bytesRead } = await fd.read(buf, 0, len, 0);
    const header = buf.subarray(0, bytesRead);
    if (header.indexOf(0) !== -1) return true;
    try { new TextDecoder("utf-8", { fatal: true }).decode(header, { stream: true }); return false; }
    catch { return true; }
  } finally { await fd.close(); }
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes}B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
  if (bytes < 1024 * 1024 * 1024) return `${(bytes / (1024 * 1024)).toFixed(1)}MB`;
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)}GB`;
}
import type { ExtractedContent } from "./fetch-content";
import { isGhAvailable, execGhAsync } from "./gh-utils";

const CLONE_BASE = join(homedir(), "Development", "repos");

const NOISE_DIRS = new Set([
  "node_modules", "vendor", ".next", "dist", "build", "__pycache__",
  ".venv", "venv", ".tox", ".mypy_cache", ".pytest_cache",
  "target", ".gradle", ".idea", ".vscode",
]);

const NON_CODE = new Set([
  "issues", "pull", "pulls", "discussions", "releases", "wiki",
  "actions", "settings", "security", "projects", "graphs",
  "compare", "commits", "tags", "branches", "stargazers",
  "watchers", "network", "forks", "milestone", "labels",
  "packages", "codespaces", "contribute", "community",
  "sponsors", "invitations", "notifications", "insights",
]);

/* ---- Types ---- */

interface GitHubUrlInfo {
  owner: string;
  repo: string;
  ref?: string;
  path?: string;
  type: "root" | "blob" | "tree";
}

const MAX_TREE = 200;
const MAX_INLINE = 100_000;
const CLONE_TIMEOUT_MS = 30_000;
const MAX_REPO_MB = 350;

/* ---- URL parsing (sync, no I/O) ---- */

export function parseGitHubUrl(url: string): GitHubUrlInfo | null {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return null;
  }

  const host = parsed.hostname.toLowerCase();
  if (host !== "github.com" && host !== "www.github.com") return null;

  const segs = parsed.pathname.split("/").filter(Boolean).map((s) => {
    try {
      return decodeURIComponent(s);
    } catch {
      return s;
    }
  });
  if (segs.length < 2) return null;

  const owner = segs[0];
  const repo = segs[1].replace(/\.git$/, "");

  if (NON_CODE.has(segs[2]?.toLowerCase())) return null;

  if (segs.length === 2) return { owner, repo, type: "root" };

  const action = segs[2];
  if (action !== "blob" && action !== "tree") return null;
  if (segs.length < 4) return null;

  const ref = segs[3];
  const pathParts = segs.slice(4);
  return {
    owner,
    repo,
    ref,
    path: pathParts.length > 0 ? pathParts.join("/") : "",
    type: action as "blob" | "tree",
  };
}

/* ---- Cloning ---- */



function cloneDir(owner: string, repo: string, ref?: string): string {
  return ref ? join(CLONE_BASE, owner, `${repo}@${ref}`) : join(CLONE_BASE, owner, repo);
}

async function cloneRepo(owner: string, repo: string, ref?: string): Promise<string | null> {
  const localPath = cloneDir(owner, repo, ref);
  await fs.rm(localPath, { recursive: true, force: true });

  const hasGh = await isGhAvailable();

  const runClone = (args: string[]): Promise<string | null> =>
    new Promise((resolve) => {
      execFile(args[0], args.slice(1), { timeout: CLONE_TIMEOUT_MS }, async (err) => {
        if (err) {
          await fs.rm(localPath, { recursive: true, force: true });
          resolve(null);
          return;
        }
        resolve(localPath);
      });
    });

  if (hasGh) {
    const args = ["gh", "repo", "clone", `${owner}/${repo}`, localPath, "--", "--depth", "1", "--single-branch"];
    if (ref) args.push("--branch", ref);
    return runClone(args);
  }

  const gitUrl = `https://github.com/${owner}/${repo}.git`;
  const args = ["git", "clone", "--depth", "1", "--single-branch"];
  if (ref) args.push("--branch", ref);
  args.push(gitUrl, localPath);
  return runClone(args);
}

/* ---- API fallback ---- */

async function checkRepoSizeMB(owner: string, repo: string): Promise<number | null> {
  if (!(await isGhAvailable())) return null;
  try {
    const stdout = await execGhAsync(["api", `repos/${owner}/${repo}`, "--jq", ".size"], { timeout: 10000 });
    const kb = parseInt(stdout.trim(), 10);
    return Number.isNaN(kb) ? null : kb / 1024;
  } catch {
    return null;
  }
}

async function fetchDefaultBranch(owner: string, repo: string): Promise<string | null> {
  if (!(await isGhAvailable())) return null;
  try {
    const stdout = await execGhAsync(["api", `repos/${owner}/${repo}`, "--jq", ".default_branch"], { timeout: 10000 });
    return stdout.trim() || null;
  } catch {
    return null;
  }
}

async function fetchTreeViaApi(owner: string, repo: string, ref: string): Promise<string | null> {
  if (!(await isGhAvailable())) return null;
  try {
    const stdout = await execGhAsync(
      ["api", `repos/${owner}/${repo}/git/trees/${ref}?recursive=1`, "--jq", ".tree[].path"],
      { timeout: 15000, maxBuffer: 5 * 1024 * 1024 },
    );
    const paths = stdout.trim().split("\n").filter(Boolean);
    if (paths.length === 0) return null;
    const truncated = paths.length > MAX_TREE;
    const display = paths.slice(0, MAX_TREE).join("\n");
    return truncated ? display + `\n... (${paths.length} total entries)` : display;
  } catch {
    return null;
  }
}

async function fetchReadmeViaApi(owner: string, repo: string, ref: string): Promise<string | null> {
  if (!(await isGhAvailable())) return null;
  try {
    const stdout = await execGhAsync(
      ["api", `repos/${owner}/${repo}/readme?ref=${ref}`, "--jq", ".content"],
      { timeout: 10000 },
    );
    const decoded = Buffer.from(stdout.trim(), "base64").toString("utf-8");
    return decoded.length > 8192 ? decoded.slice(0, 8192) + "\n\n[README truncated at 8K chars]" : decoded;
  } catch {
    return null;
  }
}

async function fetchFileViaApi(owner: string, repo: string, path: string, ref: string): Promise<string | null> {
  if (!(await isGhAvailable())) return null;
  try {
    const stdout = await execGhAsync(
      ["api", `repos/${owner}/${repo}/contents/${path}?ref=${ref}`, "--jq", ".content"],
      { timeout: 10000, maxBuffer: 2 * 1024 * 1024 },
    );
    return Buffer.from(stdout.trim(), "base64").toString("utf-8");
  } catch {
    return null;
  }
}

/* ---- Async content helpers ---- */

async function exists(path: string): Promise<boolean> {
  try {
    await fs.access(path, fsc.F_OK);
    return true;
  } catch {
    return false;
  }
}

async function resolveWithin(rootPath: string, relative: string): Promise<string | null> {
  const normalized = resolvePath(rootPath);
  const candidate = resolvePath(normalized, relative);
  if (!candidate.startsWith(normalized.endsWith(pathSep) ? normalized : normalized + pathSep)) return null;

  const candidateExists = await exists(candidate);
  if (!candidateExists) return candidate;

  try {
    const realRoot = await fs.realpath(normalized);
    const realCandidate = await fs.realpath(candidate);
    if (!realCandidate.startsWith(realRoot.endsWith(pathSep) ? realRoot : realRoot + pathSep)) return null;
  } catch {
    return null;
  }
  return candidate;
}



async function buildTree(rootPath: string): Promise<string> {
  const entries: string[] = [];

  async function walk(dir: string, rel: string): Promise<void> {
    if (entries.length >= MAX_TREE) return;
    let items: string[];
    try {
      items = (await fs.readdir(dir)).sort();
    } catch {
      return;
    }
    for (const item of items) {
      if (entries.length >= MAX_TREE) return;
      if (item === ".git") continue;
      const r = rel ? `${rel}/${item}` : item;
      const safe = await resolveWithin(rootPath, r);
      if (!safe) {
        entries.push(`${r}  [outside repo]`);
        continue;
      }
      let st;
      try {
        st = await fs.stat(safe);
      } catch {
        continue;
      }
      if (st.isDirectory()) {
        if (NOISE_DIRS.has(item)) {
          entries.push(`${r}/  [skipped]`);
          continue;
        }
        entries.push(`${r}/`);
        await walk(safe, r);
      } else {
        entries.push(r);
      }
    }
  }

  await walk(rootPath, "");
  if (entries.length >= MAX_TREE) entries.push(`... (truncated at ${MAX_TREE} entries)`);
  return entries.join("\n");
}

async function buildDirListing(rootPath: string, subPath: string): Promise<string> {
  const target = await resolveWithin(rootPath, subPath);
  if (!target) return "(path escapes repo root)";
  let items: string[];
  try {
    items = (await fs.readdir(target)).sort();
  } catch {
    return "(directory not readable)";
  }
  const lines: string[] = [];
  for (const item of items) {
    if (item === ".git") continue;
    const r = subPath ? `${subPath}/${item}` : item;
    const safe = await resolveWithin(rootPath, r);
    if (!safe) {
      lines.push(`  ${item}  (outside repo)`);
      continue;
    }
    try {
      const st = await fs.stat(safe);
      lines.push(st.isDirectory() ? `  ${item}/` : `  ${item}  (${formatBytes(st.size)})`);
    } catch {
      lines.push(`  ${item}  (unreadable)`);
    }
  }
  return lines.join("\n");
}

async function readReadme(localPath: string): Promise<string | null> {
  for (const name of ["README.md", "readme.md", "README", "README.txt", "README.rst"]) {
    const p = join(localPath, name);
    const pExists = await exists(p);
    if (!pExists) continue;
    try {
      const content = await fs.readFile(p, "utf-8");
      return content.length > 8192 ? content.slice(0, 8192) + "\n\n[README truncated at 8K chars]" : content;
    } catch {
      continue;
    }
  }
  return null;
}

async function readTextFile(path: string): Promise<string | null> {
  try {
    return await fs.readFile(path, "utf-8");
  } catch {
    return null;
  }
}

async function generateContent(localPath: string, info: GitHubUrlInfo): Promise<string> {
  const lines: string[] = [];
  lines.push(`Repository cloned to: ${localPath}`);
  lines.push("");

  if (info.type === "root") {
    lines.push("## Structure");
    lines.push(await buildTree(localPath));
    lines.push("");
    const readme = await readReadme(localPath);
    if (readme) {
      lines.push("## README.md");
      lines.push(readme);
      lines.push("");
    }
    lines.push("Use `read` and `bash` tools at the path above to explore further.");
    return lines.join("\n");
  }

  const pathPart = info.path || "";
  const fullPath = await resolveWithin(localPath, pathPart);

  if (!fullPath || !(await exists(fullPath))) {
    lines.push(`Path \`${pathPart}\` not found in clone.`);
    lines.push("");
    lines.push("## Structure");
    lines.push(await buildTree(localPath));
    lines.push("");
    lines.push("Use `read` and `bash` tools at the path above to explore further.");
    return lines.join("\n");
  }

  let st;
  try {
    st = await fs.stat(fullPath);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    lines.push(`Could not inspect \`${pathPart}\`: ${msg}`);
    return lines.join("\n");
  }

  if (st.isDirectory()) {
    lines.push(`## ${pathPart || "/"}`);
    lines.push(await buildDirListing(localPath, pathPart));
    lines.push("");
    lines.push("Use `read` and `bash` tools at the path above to explore further.");
    return lines.join("\n");
  }

  if (await isProbablyBinary(fullPath)) {
    const ext = extname(pathPart).replace(".", "");
    lines.push(`## ${pathPart}`);
    lines.push(`Binary file (${ext}, ${formatBytes(st.size)}). Use \`read\` or \`bash\` to inspect.`);
    return lines.join("\n");
  }

  const content = await readTextFile(fullPath);
  if (content === null) {
    lines.push(`Could not read \`${pathPart}\` as UTF-8 text.`);
    return lines.join("\n");
  }

  lines.push(`## ${pathPart}`);
  if (content.length > MAX_INLINE) {
    lines.push(content.slice(0, MAX_INLINE));
    lines.push("");
    lines.push(`[File truncated at 100K chars. Full file: ${fullPath}]`);
  } else {
    lines.push(content);
  }
  lines.push("");
  lines.push("Use `read` and `bash` tools at the path above to explore further.");
  return lines.join("\n");
}

/* ---- Main entry ---- */

export async function extractGitHub(
  url: string,
  signal?: AbortSignal,
  forceClone?: boolean,
): Promise<ExtractedContent | null> {
  const info = parseGitHubUrl(url);
  if (!info) return null;
  if (signal?.aborted) return null;

  const { owner, repo } = info;

  // SHA refs → API only (can't clone a specific commit easily with depth=1)
  if (info.ref && /^[0-9a-f]{40}$/.test(info.ref)) {
    const ref = info.ref;
    if (info.type === "blob" && info.path) {
      const content = await fetchFileViaApi(owner, repo, info.path, ref);
      if (!content) return null;
      return {
        url,
        title: `${owner}/${repo} - ${info.path}`,
        content: `## ${info.path}\n\n${content.length > MAX_INLINE ? content.slice(0, MAX_INLINE) + `\n\n[File truncated at 100K chars]` : content}\n\nUse \`read\` and \`bash\` tools to explore further.`,
        error: null,
      };
    }
    const [tree, readme] = await Promise.all([
      fetchTreeViaApi(owner, repo, ref),
      fetchReadmeViaApi(owner, repo, ref),
    ]);
    if (!tree && !readme) return null;
    const lines: string[] = [];
    if (tree) { lines.push("## Structure"); lines.push(tree); lines.push(""); }
    if (readme) { lines.push("## README.md"); lines.push(readme); lines.push(""); }
    lines.push("Commit SHA URLs use API view (not cloned). Use `read`/`bash` for deeper exploration.");
    return { url, title: `${owner}/${repo}`, content: lines.join("\n"), error: null };
  }

  // Size check (skip if forceClone)
  if (!forceClone) {
    const sizeMB = await checkRepoSizeMB(owner, repo);
    if (sizeMB !== null && sizeMB > MAX_REPO_MB) {
      const ref = info.ref || (await fetchDefaultBranch(owner, repo));
      if (!ref) return null;
      const sizeNote =
        `Repository is ~${Math.round(sizeMB)}MB (threshold: ${MAX_REPO_MB}MB). ` +
        `Showing API-fetched content instead. Use read or bash to explore files individually.`;
      const [tree, readme] = await Promise.all([
        fetchTreeViaApi(owner, repo, ref),
        fetchReadmeViaApi(owner, repo, ref),
      ]);
      const lines: string[] = [sizeNote, ""];
      if (tree) { lines.push("## Structure"); lines.push(tree); lines.push(""); }
      if (readme) { lines.push("## README.md"); lines.push(readme); lines.push(""); }
      lines.push("Use `read`/`bash` tools or force clone to explore further.");
      return { url, title: `${owner}/${repo}`, content: lines.join("\n"), error: null };
    }
  }

  if (signal?.aborted) return null;

  const localPath = await cloneRepo(owner, repo, info.ref);
  if (!localPath) {
    // Fallback to API
    const ref = info.ref || (await fetchDefaultBranch(owner, repo));
    if (!ref) return null;
    if (info.type === "blob" && info.path) {
      const content = await fetchFileViaApi(owner, repo, info.path, ref);
      if (!content) return null;
      return {
        url,
        title: `${owner}/${repo} - ${info.path}`,
        content: `## ${info.path}\n\n${content.length > MAX_INLINE ? content.slice(0, MAX_INLINE) + `\n\n[File truncated]` : content}`,
        error: null,
      };
    }
    const [tree, readme] = await Promise.all([
      fetchTreeViaApi(owner, repo, ref),
      fetchReadmeViaApi(owner, repo, ref),
    ]);
    if (!tree && !readme) return null;
    const lines: string[] = [];
    if (tree) { lines.push("## Structure"); lines.push(tree); lines.push(""); }
    if (readme) { lines.push("## README.md"); lines.push(readme); lines.push(""); }
    lines.push("Clone failed. Showing API view. Use `read`/`bash` for deeper exploration.");
    return { url, title: `${owner}/${repo}`, content: lines.join("\n"), error: null };
  }

  const content = await generateContent(localPath, info);
  const title = info.path ? `${owner}/${repo} - ${info.path}` : `${owner}/${repo}`;
  return { url, title, content, error: null };
}
