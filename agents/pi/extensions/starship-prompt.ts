/**
 * Starship-style prompt for pi.
 *
 * Single info line above the editor, `❯` prompt, no borders, no footer.
 */

import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
  type Theme,
} from "@mariozechner/pi-coding-agent";
import type { TUI, EditorTheme, EditorOptions } from "@mariozechner/pi-tui";
import type { KeybindingsManager } from "@mariozechner/pi-coding-agent";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import { visibleWidth, CURSOR_MARKER } from "@mariozechner/pi-tui";
import { exec } from "node:child_process";
import { promisify } from "node:util";

const execAsync = promisify(exec);

// ── vcs (git/jj) ─────────────────────────────────────────────────────────

interface VcsInfo {
  type: "git" | "jj";
  branch: string;
  commit: string;
  commitRest?: string; // remaining chars after commit (jj only)
  dirty: boolean;
}

interface VcsCache {
  info: VcsInfo | null;
  time: number;
  cwd: string;
  promise: Promise<void> | null;
}

const vcs: VcsCache = {
  info: null,
  time: 0,
  cwd: "",
  promise: null,
};

const CACHE_TTL = 2000;
const EXEC_TIMEOUT = 300;

async function getVcsInfo(
  cwd: string,
  ctx: ExtensionContext,
): Promise<VcsInfo | null> {
  const execOptions = { cwd, timeout: EXEC_TIMEOUT };

  // Try jj first (no existence check - just try it)
  try {
    const { stdout } = await execAsync(
      'jj log -r @ --no-graph -T \'change_id.shortest() ++ "\\n" ++ change_id.shortest(8) ++ "\\n" ++ self.bookmarks().join(", ")\'',
      execOptions,
    );

    const lines = stdout.trim().split("\n");

    const commitShort = lines[0]?.trim() ?? ""; // e.g., "nv"
    const commitLong = lines[1]?.trim() ?? ""; // e.g., "nvpouuzo"
    const commitRest = commitLong.slice(commitShort.length); // e.g., "pouuzo"
    const bookmark = lines[2]?.trim().replace("*", ""); // empty string if no bookmarks

    const dirty = await execAsync("jj diff --stat", execOptions)
      .then(({ stdout }) => stdout.trim().length > 0)
      .catch(() => false);

    return {
      type: "jj",
      branch: bookmark,
      commit: commitShort,
      commitRest,
      dirty,
    };
  } catch {
    // Not a jj repo or jj failed - fall through to git
  }

  // Try git (also works for colocated jj repos when jj fails)
  try {
    const [{ stdout: branchOut }, { stdout: commitOut }] = await Promise.all([
      execAsync("git branch --show-current", execOptions),
      execAsync("git rev-parse --short HEAD", execOptions),
    ]);

    const branch = branchOut.trim() || "HEAD";
    const commit = commitOut.trim();

    const dirty = await execAsync("git diff-index --quiet HEAD --", execOptions)
      .then(() => false)
      .catch(() => true);

    return { type: "git", branch, commit, dirty };
  } catch {
    // Not a git repo
    return null;
  }
}

async function refreshVcs(
  cwd: string,
  ctx: ExtensionContext,
  cb?: () => void,
): Promise<void> {
  const now = Date.now();

  // Return cached if valid and same cwd
  if (vcs.cwd === cwd && now - vcs.time < CACHE_TTL) {
    cb?.();
    return;
  }

  // Return existing promise if refresh in flight
  if (vcs.promise) {
    await vcs.promise;
    cb?.();
    return;
  }

  // Start new refresh with promise-based deduping
  vcs.promise = (async () => {
    vcs.cwd = cwd;
    vcs.time = now;
    try {
      vcs.info = await getVcsInfo(cwd, ctx);
    } finally {
      vcs.promise = null;
    }
  })();

  await vcs.promise;
  cb?.();
}

// ── helpers ──────────────────────────────────────────────────────────────

const tk = (n: number) => {
  if (n < 1000) return `${n}`;
  if (n >= 1000000) {
    const m = n / 1000000;
    return m.toFixed(m < 10 ? 1 : 0).replace(/\.0$/, "") + "M";
  }
  const k = n / 1000;
  return k.toFixed(k < 10 ? 1 : 0).replace(/\.0$/, "") + "k";
};

// ── prompt line (widget) ─────────────────────────────────────────────────

function buildPromptLine(
  t: Theme,
  ctx: ExtensionContext,
  pi: ExtensionAPI,
): string[] {
  const p: string[] = [];
  p.push(t.bold(t.fg("mdHeading", ` ) `)));

  const cwd = process.cwd();
  const home = process.env.HOME || "";
  const dir = cwd.startsWith(home) ? "~" + cwd.slice(home.length) : cwd;
  p.push(t.bold(t.fg("error", dir)));

  // vcs (git/jj)
  if (vcs.info) {
    p.push(" on ");
    if (vcs.info.type === "git") {
      // git: branch with  symbol, then commit in parens
      p.push(t.fg("accent", ` ${vcs.info.branch}`));
      if (vcs.info.dirty) {
        p.push(t.bold(t.fg("error", "*")));
      }
      p.push(" (");
      p.push(t.bold(t.fg("accent", vcs.info.commit)));
      p.push(")");
    } else {
      // jj: commit (short bold + rest dimmed), then bookmark in parens if exists
      p.push(t.bold(t.fg("accent", ` ${vcs.info.commit}`)));
      if (vcs.info.commitRest) {
        p.push(t.fg("dim", vcs.info.commitRest));
        if (vcs.info.dirty) {
          p.push(t.bold(t.fg("error", "*")));
        }
      }
      if (vcs.info.branch) {
        p.push(t.fg("dim", ` (${vcs.info.branch})`));
      }
    }
  }

  // model: via model
  if (ctx.model?.id) {
    p.push(" via ");
    p.push(t.bold(t.fg("syntaxString", ` ${ctx.model.id}`)));
  }

  // thinking
  const lvl = pi.getThinkingLevel();
  if (lvl !== "off") {
    const c: Record<string, Parameters<Theme["fg"]>[0]> = {
      minimal: "thinkingMinimal",
      low: "thinkingLow",
      medium: "thinkingMedium",
      high: "thinkingHigh",
      xhigh: "thinkingXhigh",
    };
    // lightning bolt
    p.push(" " + t.bold(t.fg(c[lvl] ?? "warning", `󱐋 ${lvl}`)));
  }

  // stats (tokens/cost/context) - dim
  const branch = ctx.sessionManager.getBranch();

  // Calculate cumulative tokens and cost from all assistant messages
  let inp = 0,
    out = 0,
    cacheRead = 0,
    cost = 0;

  for (const e of branch) {
    if (e.type === "message" && e.message.role === "assistant") {
      const m = e.message as AssistantMessage;
      inp += m.usage.input;
      out += m.usage.output;
      cacheRead += m.usage.cacheRead || 0;
      cost += m.usage.cost.total;
    }
  }

  // Always show stats (even if 0)
  p.push(t.fg("dim", " · "));

  // Token counts: input (with cached reads in dim), output (always fresh)
  p.push(
    t.fg("syntaxFunction", `↑ ${tk(inp)}`) +
      (cacheRead > 0 ? t.fg("dim", `/${tk(cacheRead)}`) : "") +
      " " +
      t.fg("syntaxString", `↓ ${tk(out)}`),
  );
  if (cost > 0) p.push(t.fg("dim", ` $${cost.toFixed(4)}`));

  // context usage
  const usage = ctx.getContextUsage();
  if (usage) {
    const limit = ctx.model?.contextWindow ?? usage.limit;
    const pct = limit > 0 ? (usage.tokens / limit) * 100 : 0;
    const color: Parameters<Theme["fg"]>[0] =
      limit > 0
        ? pct > 85
          ? "error"
          : pct > 60
            ? "warning"
            : "success"
        : "dim";
    const limitStr = limit > 0 ? tk(limit) : "???";
    p.push(" · " + t.fg(color, `󰍛 ${tk(usage.tokens)}/${limitStr}`));
  }

  return [p.join("")];
}

// ── borderless editor with ❯ prompt ──────────────────────────────────────

class PromptEditor extends CustomEditor {
  private appTheme: Theme;

  constructor(
    tui: TUI,
    editorTheme: EditorTheme,
    kb: KeybindingsManager,
    appTheme: Theme,
    opts?: EditorOptions,
  ) {
    super(tui, editorTheme, kb, opts);
    this.appTheme = appTheme;
  }

  render(width: number): string[] {
    const prompt = this.appTheme.bold(this.appTheme.fg("success", "❯")) + " ";
    const promptW = visibleWidth(prompt);
    const innerW = Math.max(10, width - promptW);

    // suppress borders → they become ""
    const origBorder = this.borderColor;
    this.borderColor = () => "";
    const raw = super.render(innerW);
    this.borderColor = origBorder;

    // strip empty border lines
    const lines = raw.filter((l) => l !== "");
    if (lines.length === 0)
      return [prompt + (this.focused ? CURSOR_MARKER : "")];

    const indent = " ".repeat(promptW);
    return [prompt + lines[0], ...lines.slice(1).map((l) => indent + l)];
  }
}

// ── extension ────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  let bashDebounceTimer: NodeJS.Timeout | null = null;
  const BASH_DEBOUNCE_MS = 300;

  function update(ctx: ExtensionContext) {
    ctx.ui.setWidget("starship", buildPromptLine(ctx.ui.theme, ctx, pi));
  }

  function vcsThenUpdate(ctx: ExtensionContext) {
    vcs.time = 0;
    refreshVcs(process.cwd(), ctx, () => update(ctx));
  }

  // Debounced VCS refresh for bash events - cancels pending refresh if another arrives
  function debouncedVcsUpdate(ctx: ExtensionContext) {
    if (bashDebounceTimer) clearTimeout(bashDebounceTimer);
    bashDebounceTimer = setTimeout(() => {
      bashDebounceTimer = null;
      vcsThenUpdate(ctx);
    }, BASH_DEBOUNCE_MS);
  }

  pi.on("session_start", (_ev, ctx) => {
    // empty footer
    ctx.ui.setFooter((_tui, _theme) => ({
      invalidate() {},
      render() {
        return [];
      },
    }));

    // custom editor: no borders, ❯ prompt
    ctx.ui.setEditorComponent(
      (tui, editorTheme, kb) =>
        new PromptEditor(tui, editorTheme, kb, ctx.ui.theme),
    );

    vcsThenUpdate(ctx);
  });

  pi.on("session_switch", (_ev, ctx) => vcsThenUpdate(ctx));
  pi.on("agent_start", (_ev, ctx) => update(ctx));
  pi.on("turn_end", (_ev, ctx) => update(ctx));
  pi.on("agent_end", (_ev, ctx) => update(ctx));
  pi.on("model_select", (_ev, ctx) => update(ctx));
  pi.on("user_bash", (_ev, ctx) => debouncedVcsUpdate(ctx));
}
