/**
 * Code Review Extension
 *
 * Provides a `/review` command that prompts the agent to review code changes.
 * Supports multiple review modes:
 * - Review against a base branch (PR style)
 * - Review uncommitted changes
 * - Review a specific commit
 * - Review specific folders/files (snapshot, not diff)
 * - Custom review instructions
 *
 * Usage:
 * - `/review` - show interactive selector
 * - `/review uncommitted` - review uncommitted changes directly
 * - `/review branch main` - review against main branch
 * - `/review commit abc123` - review specific commit
 * - `/review folder src docs` - review specific folders/files (snapshot, not diff)
 * - `/review custom "check for security issues"` - custom instructions
 *
 * Project-specific review guidelines:
 * - If a REVIEW_GUIDELINES.md file exists in the same directory as .pi,
 *   its contents are appended to the review prompt.
 *
 * Fresh session mode:
 * - When selected, starts from a clean slate (navigates to first user message)
 * - Use /end-review to return to original position with options to summarize/fix
 */

import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { DynamicBorder, BorderedLoader } from "@mariozechner/pi-coding-agent";
import { Container, type SelectItem, SelectList, Text } from "@mariozechner/pi-tui";
import path from "node:path";
import { promises as fs } from "node:fs";

// State to track fresh session review (where we branched from).
let reviewOriginId: string | undefined = undefined;
let endReviewInProgress = false;

const REVIEW_STATE_TYPE = "review-session";

type ReviewSessionState = {
    active: boolean;
    originId?: string;
};

function setReviewWidget(ctx: ExtensionContext, active: boolean) {
    if (!ctx.hasUI) return;
    if (!active) {
        ctx.ui.setWidget("review", undefined);
        return;
    }

    ctx.ui.setWidget("review", (_tui, theme) => {
        const text = new Text(theme.fg("warning", "Review session active, return with /end-review"), 0, 0);
        return {
            render(width: number) {
                return text.render(width);
            },
            invalidate() {
                text.invalidate();
            },
        };
    });
}

function getReviewState(ctx: ExtensionContext): ReviewSessionState | undefined {
    for (const entry of ctx.sessionManager.getBranch()) {
        if (entry.type === "custom" && entry.customType === REVIEW_STATE_TYPE) {
            return entry.data as ReviewSessionState | undefined;
        }
    }
    return undefined;
}

function applyReviewState(ctx: ExtensionContext) {
    const state = getReviewState(ctx);

    if (state?.active && state.originId) {
        reviewOriginId = state.originId;
        setReviewWidget(ctx, true);
        return;
    }

    reviewOriginId = undefined;
    setReviewWidget(ctx, false);
}

// Review target types
type ReviewTarget =
    | { type: "uncommitted" }
    | { type: "baseBranch"; branch: string }
    | { type: "commit"; sha: string; title?: string }
    | { type: "custom"; instructions: string }
    | { type: "folder"; paths: string[] };

// Prompts
const UNCOMMITTED_PROMPT =
    "Review the current code changes (staged, unstaged, and untracked files) and provide prioritized findings.";

const BASE_BRANCH_PROMPT_WITH_MERGE_BASE =
    "Review the code changes against the base branch '{baseBranch}'. The merge base commit for this comparison is {mergeBaseSha}. Run `git diff {mergeBaseSha}` to inspect the changes relative to {baseBranch}. Provide prioritized, actionable findings.";

const BASE_BRANCH_PROMPT_FALLBACK =
    "Review the code changes against the base branch '{branch}'. Start by finding the merge diff between the current branch and {branch}'s upstream e.g. (`git merge-base HEAD \"$(git rev-parse --abbrev-ref \"{branch}@{upstream}\")\"`), then run `git diff` against that SHA to see what changes we would merge into the {branch} branch. Provide prioritized, actionable findings.";

const COMMIT_PROMPT_WITH_TITLE =
    'Review the code changes introduced by commit {sha} ("{title}"). Provide prioritized, actionable findings.';

const COMMIT_PROMPT = "Review the code changes introduced by commit {sha}. Provide prioritized, actionable findings.";

const FOLDER_REVIEW_PROMPT =
    "Review the code in the following paths: {paths}. This is a snapshot review (not a diff). Read the files directly in these paths and provide prioritized, actionable findings.";

// The detailed review rubric
const REVIEW_RUBRIC = `# Review Guidelines

You are acting as a code reviewer for a proposed code change made by another engineer.

Below are default guidelines for determining what to flag. These are not the final word — if you encounter more specific guidelines elsewhere (in a developer message, user message, file, or project review guidelines appended below), those override these general instructions.

## Determining what to flag

Flag issues that:
1. Meaningfully impact the accuracy, performance, security, or maintainability of the code.
2. Are discrete and actionable (not general issues or multiple combined issues).
3. Don't demand rigor inconsistent with the rest of the codebase.
4. Were introduced in the changes being reviewed (not pre-existing bugs).
5. The author would likely fix if aware of them.
6. Don't rely on unstated assumptions about the codebase or author's intent.
7. Have provable impact on other parts of the code — it is not enough to speculate that a change may disrupt another part, you must identify the parts that are provably affected.
8. Are clearly not intentional changes by the author.
9. Be particularly careful with untrusted user input and follow the specific guidelines to review.

## Untrusted User Input

1. Be careful with open redirects, they must always be checked to only go to trusted domains (?next_page=...)
2. Always flag SQL that is not parametrized
3. In systems with user supplied URL input, http fetches always need to be protected against access to local resources (intercept DNS resolver!)
4. Escape, don't sanitize if you have the option (eg: HTML escaping)

## Comment guidelines

1. Be clear about why the issue is a problem.
2. Communicate severity appropriately - don't exaggerate.
3. Be brief - at most 1 paragraph.
4. Keep code snippets under 3 lines, wrapped in inline code or code blocks.
5. Use \`\`\`suggestion blocks ONLY for concrete replacement code (minimal lines; no commentary inside the block). Preserve the exact leading whitespace of the replaced lines.
6. Explicitly state scenarios/environments where the issue arises.
7. Use a matter-of-fact tone - helpful AI assistant, not accusatory.
8. Write for quick comprehension without close reading.
9. Avoid excessive flattery or unhelpful phrases like "Great job...".

## Review priorities

1. Call out newly added dependencies explicitly and explain why they're needed.
2. Prefer simple, direct solutions over wrappers or abstractions without clear value.
3. Favor fail-fast behavior; avoid logging-and-continue patterns that hide errors.
4. Prefer predictable production behavior; crashing is better than silent degradation.
5. Treat back pressure handling as critical to system stability.
6. Apply system-level thinking; flag changes that increase operational risk or on-call wakeups.
7. Ensure that errors are always checked against codes or stable identifiers, never error messages.

## Priority levels

Tag each finding with a priority level in the title:
- [P0] - Drop everything to fix. Blocking release/operations. Only for universal issues that do not depend on assumptions about inputs.
- [P1] - Urgent. Should be addressed in the next cycle.
- [P2] - Normal. To be fixed eventually.
- [P3] - Low. Nice to have.

## Output format

Provide your findings in a clear, structured format:
1. List each finding with its priority tag, file location, and explanation.
2. Findings must reference locations that overlap with the actual diff — don't flag pre-existing code.
3. Keep line references as short as possible (avoid ranges over 5-10 lines; pick the most suitable subrange).
4. At the end, provide an overall verdict: "correct" (no blocking issues) or "needs attention" (has blocking issues).
5. Ignore trivial style issues unless they obscure meaning or violate documented standards.
6. Do not generate a full PR fix — only flag issues and optionally provide short suggestion blocks.

Output all findings the author would fix if they knew about them. If there are no qualifying findings, explicitly state the code looks good. Don't stop at the first finding - list every qualifying issue.`;

async function loadProjectReviewGuidelines(cwd: string): Promise<string | null> {
    let currentDir = path.resolve(cwd);

    while (true) {
        const piDir = path.join(currentDir, ".pi");
        const guidelinesPath = path.join(currentDir, "REVIEW_GUIDELINES.md");

        const piStats = await fs.stat(piDir).catch(() => null);
        if (piStats?.isDirectory()) {
            const guidelineStats = await fs.stat(guidelinesPath).catch(() => null);
            if (guidelineStats?.isFile()) {
                try {
                    const content = await fs.readFile(guidelinesPath, "utf8");
                    const trimmed = content.trim();
                    return trimmed || null;
                } catch {
                    return null;
                }
            }
            return null;
        }

        const parentDir = path.dirname(currentDir);
        if (parentDir === currentDir) return null;
        currentDir = parentDir;
    }
}

/**
 * Get the merge base between HEAD and a branch
 */
async function getMergeBase(pi: ExtensionAPI, branch: string): Promise<string | null> {
    try {
        const { stdout: upstream, code: upstreamCode } = await pi.exec("git", [
            "rev-parse",
            "--abbrev-ref",
            `${branch}@{upstream}`,
        ]);

        if (upstreamCode === 0 && upstream.trim()) {
            const { stdout: mergeBase, code } = await pi.exec("git", ["merge-base", "HEAD", upstream.trim()]);
            if (code === 0 && mergeBase.trim()) return mergeBase.trim();
        }

        const { stdout: mergeBase, code } = await pi.exec("git", ["merge-base", "HEAD", branch]);
        if (code === 0 && mergeBase.trim()) return mergeBase.trim();

        return null;
    } catch {
        return null;
    }
}

/**
 * Get list of local branches
 */
async function getLocalBranches(pi: ExtensionAPI): Promise<string[]> {
    const { stdout, code } = await pi.exec("git", ["branch", "--format=%(refname:short)"]);
    if (code !== 0) return [];
    return stdout.trim().split("\n").filter((b) => b.trim());
}

/**
 * Get list of recent commits
 */
async function getRecentCommits(pi: ExtensionAPI, limit = 10): Promise<Array<{ sha: string; title: string }>> {
    const { stdout, code } = await pi.exec("git", ["log", "--oneline", `-n`, `${limit}`]);
    if (code !== 0) return [];

    return stdout
        .trim()
        .split("\n")
        .filter((line) => line.trim())
        .map((line) => {
            const [sha, ...rest] = line.trim().split(" ");
            return { sha, title: rest.join(" ") };
        });
}

/**
 * Check if there are uncommitted changes
 */
async function hasUncommittedChanges(pi: ExtensionAPI): Promise<boolean> {
    const { stdout, code } = await pi.exec("git", ["status", "--porcelain"]);
    return code === 0 && stdout.trim().length > 0;
}

/**
 * Get the current branch name
 */
async function getCurrentBranch(pi: ExtensionAPI): Promise<string | null> {
    const { stdout, code } = await pi.exec("git", ["branch", "--show-current"]);
    if (code === 0 && stdout.trim()) return stdout.trim();
    return null;
}

/**
 * Get the default branch (main or master)
 */
async function getDefaultBranch(pi: ExtensionAPI): Promise<string> {
    const { stdout, code } = await pi.exec("git", ["symbolic-ref", "refs/remotes/origin/HEAD", "--short"]);
    if (code === 0 && stdout.trim()) return stdout.trim().replace("origin/", "");

    const branches = await getLocalBranches(pi);
    if (branches.includes("main")) return "main";
    if (branches.includes("master")) return "master";

    return "main";
}

/**
 * Build the review prompt based on target
 */
async function buildReviewPrompt(pi: ExtensionAPI, target: ReviewTarget): Promise<string> {
    switch (target.type) {
        case "uncommitted":
            return UNCOMMITTED_PROMPT;

        case "baseBranch": {
            const mergeBase = await getMergeBase(pi, target.branch);
            if (mergeBase) {
                return BASE_BRANCH_PROMPT_WITH_MERGE_BASE
                    .replace(/{baseBranch}/g, target.branch)
                    .replace(/{mergeBaseSha}/g, mergeBase);
            }
            return BASE_BRANCH_PROMPT_FALLBACK.replace(/{branch}/g, target.branch);
        }

        case "commit":
            if (target.title) {
                return COMMIT_PROMPT_WITH_TITLE.replace("{sha}", target.sha).replace("{title}", target.title);
            }
            return COMMIT_PROMPT.replace("{sha}", target.sha);

        case "custom":
            return target.instructions;

        case "folder":
            return FOLDER_REVIEW_PROMPT.replace("{paths}", target.paths.join(", "));
    }
}

/**
 * Get user-facing hint for the review target
 */
function getUserFacingHint(target: ReviewTarget): string {
    switch (target.type) {
        case "uncommitted":
            return "current changes";
        case "baseBranch":
            return `changes against '${target.branch}'`;
        case "commit": {
            const shortSha = target.sha.slice(0, 7);
            return target.title ? `commit ${shortSha}: ${target.title}` : `commit ${shortSha}`;
        }
        case "custom":
            return target.instructions.length > 40 ? target.instructions.slice(0, 37) + "..." : target.instructions;
        case "folder": {
            const joined = target.paths.join(", ");
            return joined.length > 40 ? `folders: ${joined.slice(0, 37)}...` : `folders: ${joined}`;
        }
    }
}

// Review preset options for the selector
const REVIEW_PRESETS = [
    { value: "uncommitted", label: "Review uncommitted changes", description: "" },
    { value: "baseBranch", label: "Review against a base branch", description: "(local)" },
    { value: "commit", label: "Review a commit", description: "" },
    { value: "folder", label: "Review a folder (or more)", description: "(snapshot, not diff)" },
    { value: "custom", label: "Custom review instructions", description: "" },
] as const;

export default function reviewExtension(pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => applyReviewState(ctx));
    pi.on("session_switch", (_event, ctx) => applyReviewState(ctx));
    pi.on("session_tree", (_event, ctx) => applyReviewState(ctx));

    /**
     * Determine the smart default review type based on git state
     */
    async function getSmartDefault(): Promise<"uncommitted" | "baseBranch" | "commit"> {
        if (await hasUncommittedChanges(pi)) return "uncommitted";

        const currentBranch = await getCurrentBranch(pi);
        const defaultBranch = await getDefaultBranch(pi);
        if (currentBranch && currentBranch !== defaultBranch) return "baseBranch";

        return "commit";
    }

    /**
     * Show the review preset selector
     */
    async function showReviewSelector(ctx: ExtensionContext): Promise<ReviewTarget | null> {
        const smartDefault = await getSmartDefault();
        const items: SelectItem[] = REVIEW_PRESETS.map((preset) => ({
            value: preset.value,
            label: preset.label,
            description: preset.description,
        }));
        const smartDefaultIndex = items.findIndex((item) => item.value === smartDefault);

        while (true) {
            const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
                const container = new Container();
                container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
                container.addChild(new Text(theme.fg("accent", theme.bold("Select a review preset"))));

                const selectList = new SelectList(items, Math.min(items.length, 10), {
                    selectedPrefix: (text) => theme.fg("accent", text),
                    selectedText: (text) => theme.fg("accent", text),
                    description: (text) => theme.fg("muted", text),
                    scrollInfo: (text) => theme.fg("dim", text),
                    noMatch: (text) => theme.fg("warning", text),
                });

                if (smartDefaultIndex >= 0) selectList.setSelectedIndex(smartDefaultIndex);

                selectList.onSelect = (item) => done(item.value);
                selectList.onCancel = () => done(null);

                container.addChild(selectList);
                container.addChild(new Text(theme.fg("dim", "Press enter to confirm or esc to go back")));
                container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

                return {
                    render(width: number) {
                        return container.render(width);
                    },
                    invalidate() {
                        container.invalidate();
                    },
                    handleInput(data: string) {
                        selectList.handleInput(data);
                        tui.requestRender();
                    },
                };
            });

            if (!result) return null;

            switch (result) {
                case "uncommitted":
                    return { type: "uncommitted" };

                case "baseBranch": {
                    const target = await showBranchSelector(ctx);
                    if (target) return target;
                    break;
                }

                case "commit": {
                    const target = await showCommitSelector(ctx);
                    if (target) return target;
                    break;
                }

                case "custom": {
                    const target = await showCustomInput(ctx);
                    if (target) return target;
                    break;
                }

                case "folder": {
                    const target = await showFolderInput(ctx);
                    if (target) return target;
                    break;
                }

                default:
                    return null;
            }
        }
    }

    /**
     * Show branch selector for base branch review
     */
    async function showBranchSelector(ctx: ExtensionContext): Promise<ReviewTarget | null> {
        const branches = await getLocalBranches(pi);
        const currentBranch = await getCurrentBranch(pi);
        const defaultBranch = await getDefaultBranch(pi);

        const candidateBranches = currentBranch ? branches.filter((b) => b !== currentBranch) : branches;

        if (candidateBranches.length === 0) {
            ctx.ui.notify(
                currentBranch ? `No other branches found (current branch: ${currentBranch})` : "No branches found",
                "error",
            );
            return null;
        }

        const sortedBranches = candidateBranches.sort((a, b) => {
            if (a === defaultBranch) return -1;
            if (b === defaultBranch) return 1;
            return a.localeCompare(b);
        });

        const items: SelectItem[] = sortedBranches.map((branch) => ({
            value: branch,
            label: branch,
            description: branch === defaultBranch ? "(default)" : "",
        }));

        const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
            const container = new Container();
            container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
            container.addChild(new Text(theme.fg("accent", theme.bold("Select base branch"))));

            const selectList = new SelectList(items, Math.min(items.length, 10), {
                selectedPrefix: (text) => theme.fg("accent", text),
                selectedText: (text) => theme.fg("accent", text),
                description: (text) => theme.fg("muted", text),
                scrollInfo: (text) => theme.fg("dim", text),
                noMatch: (text) => theme.fg("warning", text),
            });

            selectList.searchable = true;
            selectList.onSelect = (item) => done(item.value);
            selectList.onCancel = () => done(null);

            container.addChild(selectList);
            container.addChild(new Text(theme.fg("dim", "Type to filter • enter to select • esc to cancel")));
            container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

            return {
                render(width: number) {
                    return container.render(width);
                },
                invalidate() {
                    container.invalidate();
                },
                handleInput(data: string) {
                    selectList.handleInput(data);
                    tui.requestRender();
                },
            };
        });

        if (!result) return null;
        return { type: "baseBranch", branch: result };
    }

    /**
     * Show commit selector
     */
    async function showCommitSelector(ctx: ExtensionContext): Promise<ReviewTarget | null> {
        const commits = await getRecentCommits(pi, 20);

        if (commits.length === 0) {
            ctx.ui.notify("No commits found", "error");
            return null;
        }

        const items: SelectItem[] = commits.map((commit) => ({
            value: commit.sha,
            label: `${commit.sha.slice(0, 7)} ${commit.title}`,
            description: "",
        }));

        const result = await ctx.ui.custom<{ sha: string; title: string } | null>((tui, theme, _kb, done) => {
            const container = new Container();
            container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));
            container.addChild(new Text(theme.fg("accent", theme.bold("Select commit to review"))));

            const selectList = new SelectList(items, Math.min(items.length, 10), {
                selectedPrefix: (text) => theme.fg("accent", text),
                selectedText: (text) => theme.fg("accent", text),
                description: (text) => theme.fg("muted", text),
                scrollInfo: (text) => theme.fg("dim", text),
                noMatch: (text) => theme.fg("warning", text),
            });

            selectList.searchable = true;
            selectList.onSelect = (item) => {
                const commit = commits.find((c) => c.sha === item.value);
                done(commit ?? null);
            };
            selectList.onCancel = () => done(null);

            container.addChild(selectList);
            container.addChild(new Text(theme.fg("dim", "Type to filter • enter to select • esc to cancel")));
            container.addChild(new DynamicBorder((str) => theme.fg("accent", str)));

            return {
                render(width: number) {
                    return container.render(width);
                },
                invalidate() {
                    container.invalidate();
                },
                handleInput(data: string) {
                    selectList.handleInput(data);
                    tui.requestRender();
                },
            };
        });

        if (!result) return null;
        return { type: "commit", sha: result.sha, title: result.title };
    }

    /**
     * Show custom instructions input
     */
    async function showCustomInput(ctx: ExtensionContext): Promise<ReviewTarget | null> {
        const result = await ctx.ui.editor(
            "Enter review instructions:",
            "Review the code for security vulnerabilities and potential bugs...",
        );

        if (!result?.trim()) return null;
        return { type: "custom", instructions: result.trim() };
    }

    function parseReviewPaths(value: string): string[] {
        return value
            .split(/\s+/)
            .map((item) => item.trim())
            .filter((item) => item.length > 0);
    }

    /**
     * Show folder input
     */
    async function showFolderInput(ctx: ExtensionContext): Promise<ReviewTarget | null> {
        const result = await ctx.ui.editor(
            "Enter folders/files to review (space-separated or one per line):",
            ".",
        );

        if (!result?.trim()) return null;
        const paths = parseReviewPaths(result);
        if (paths.length === 0) return null;

        return { type: "folder", paths };
    }

    /**
     * Execute the review
     */
    async function executeReview(ctx: ExtensionCommandContext, target: ReviewTarget, useFreshSession: boolean): Promise<void> {
        if (reviewOriginId) {
            ctx.ui.notify("Already in a review. Use /end-review to finish first.", "warning");
            return;
        }

        if (useFreshSession) {
            const originId = ctx.sessionManager.getLeafId() ?? undefined;
            if (!originId) {
                ctx.ui.notify("Failed to determine review origin. Try again from a session with messages.", "error");
                return;
            }
            reviewOriginId = originId;

            const lockedOriginId = originId;

            const entries = ctx.sessionManager.getEntries();
            const firstUserMessage = entries.find((e) => e.type === "message" && e.message.role === "user");

            if (!firstUserMessage) {
                ctx.ui.notify("No user message found in session", "error");
                reviewOriginId = undefined;
                return;
            }

            try {
                const result = await ctx.navigateTree(firstUserMessage.id, { summarize: false, label: "code-review" });
                if (result.cancelled) {
                    reviewOriginId = undefined;
                    return;
                }
            } catch (error) {
                reviewOriginId = undefined;
                ctx.ui.notify(
                    `Failed to start review: ${error instanceof Error ? error.message : String(error)}`,
                    "error",
                );
                return;
            }

            reviewOriginId = lockedOriginId;
            ctx.ui.setEditorText("");
            setReviewWidget(ctx, true);
            pi.appendEntry(REVIEW_STATE_TYPE, { active: true, originId: lockedOriginId });
        }

        const prompt = await buildReviewPrompt(pi, target);
        const hint = getUserFacingHint(target);
        const projectGuidelines = await loadProjectReviewGuidelines(ctx.cwd);

        let fullPrompt = `${REVIEW_RUBRIC}\n\n---\n\nPlease perform a code review with the following focus:\n\n${prompt}`;

        if (projectGuidelines) {
            fullPrompt += `\n\nThis project has additional instructions for code reviews:\n\n${projectGuidelines}`;
        }

        const modeHint = useFreshSession ? " (fresh session)" : "";
        ctx.ui.notify(`Starting review: ${hint}${modeHint}`, "info");

        pi.sendUserMessage(fullPrompt);
    }

    /**
     * Parse command arguments for direct invocation
     */
    function parseArgs(args: string | undefined): ReviewTarget | null {
        if (!args?.trim()) return null;

        const parts = args.trim().split(/\s+/);
        const subcommand = parts[0]?.toLowerCase();

        switch (subcommand) {
            case "uncommitted":
                return { type: "uncommitted" };

            case "branch": {
                const branch = parts[1];
                if (!branch) return null;
                return { type: "baseBranch", branch };
            }

            case "commit": {
                const sha = parts[1];
                if (!sha) return null;
                const title = parts.slice(2).join(" ") || undefined;
                return { type: "commit", sha, title };
            }

            case "custom": {
                const instructions = parts.slice(1).join(" ");
                if (!instructions) return null;
                return { type: "custom", instructions };
            }

            case "folder": {
                const paths = parseReviewPaths(parts.slice(1).join(" "));
                if (paths.length === 0) return null;
                return { type: "folder", paths };
            }

            default:
                return null;
        }
    }

    // Register the /review command
    pi.registerCommand("review", {
        description: "Review code changes (uncommitted, branch, commit, folder, or custom)",
        handler: async (args, ctx) => {
            if (!ctx.hasUI) {
                ctx.ui.notify("Review requires interactive mode", "error");
                return;
            }

            if (reviewOriginId) {
                ctx.ui.notify("Already in a review. Use /end-review to finish first.", "warning");
                return;
            }

            const { code } = await pi.exec("git", ["rev-parse", "--git-dir"]);
            if (code !== 0) {
                ctx.ui.notify("Not a git repository", "error");
                return;
            }

            let target: ReviewTarget | null = parseArgs(args);
            let fromSelector = false;

            if (!target) {
                fromSelector = true;
            }

            while (true) {
                if (!target && fromSelector) {
                    target = await showReviewSelector(ctx);
                }

                if (!target) {
                    ctx.ui.notify("Review cancelled", "info");
                    return;
                }

                const entries = ctx.sessionManager.getEntries();
                const messageCount = entries.filter((e) => e.type === "message").length;

                let useFreshSession = false;

                if (messageCount > 0) {
                    const choice = await ctx.ui.select("Start review in:", ["Empty branch", "Current session"]);

                    if (choice === undefined) {
                        if (fromSelector) {
                            target = null;
                            continue;
                        }
                        ctx.ui.notify("Review cancelled", "info");
                        return;
                    }

                    useFreshSession = choice === "Empty branch";
                }

                await executeReview(ctx, target, useFreshSession);
                return;
            }
        },
    });

    // Custom prompts for review summaries
    const REVIEW_SUMMARY_PROMPT = `We are leaving a code-review branch and returning to the main coding branch.
Create a structured handoff that can be used immediately to implement fixes.

You MUST summarize the review that happened in this branch so findings can be acted on.
Do not omit findings: include every actionable issue that was identified.

Required sections (in order):

## Review Scope
- What was reviewed (files/paths, changes, and scope)

## Verdict
- "correct" or "needs attention"

## Findings
For EACH finding, include:
- Priority tag ([P0]..[P3]) and short title
- File location (\`path/to/file.ext:line\`)
- Why it matters (brief)
- What should change (brief, actionable)

## Fix Queue
1. Ordered implementation checklist (highest priority first)

## Constraints & Preferences
- Any constraints or preferences mentioned during review
- Or "(none)"

Preserve exact file paths, function names, and error messages where available.`;

    const REVIEW_FIX_FINDINGS_PROMPT = `Use the latest review summary in this session and implement the review findings now.

Instructions:
1. Treat the summary's Findings/Fix Queue as a checklist.
2. Fix in priority order: P0, P1, then P2 (include P3 if quick and safe).
3. If a finding is invalid/already fixed/not possible right now, briefly explain why and continue.
4. Run relevant tests/checks for touched code where practical.
5. End with: fixed items, deferred/skipped items (with reasons), and verification results.`;

    type EndReviewAction = "returnOnly" | "returnAndFix" | "returnAndSummarize";

    function getActiveReviewOrigin(ctx: ExtensionContext): string | undefined {
        if (reviewOriginId) return reviewOriginId;

        const state = getReviewState(ctx);
        if (state?.active && state.originId) {
            reviewOriginId = state.originId;
            return reviewOriginId;
        }

        if (state?.active) {
            setReviewWidget(ctx, false);
            pi.appendEntry(REVIEW_STATE_TYPE, { active: false });
            ctx.ui.notify("Review state was missing origin info; cleared review status.", "warning");
        }

        return undefined;
    }

    function clearReviewState(ctx: ExtensionContext) {
        setReviewWidget(ctx, false);
        reviewOriginId = undefined;
        pi.appendEntry(REVIEW_STATE_TYPE, { active: false });
    }

    async function runEndReview(ctx: ExtensionCommandContext): Promise<void> {
        if (!ctx.hasUI) {
            ctx.ui.notify("End-review requires interactive mode", "error");
            return;
        }

        if (endReviewInProgress) {
            ctx.ui.notify("/end-review is already running", "info");
            return;
        }

        const originId = getActiveReviewOrigin(ctx);
        if (!originId) {
            if (!getReviewState(ctx)?.active) {
                ctx.ui.notify(
                    "Not in a review branch (use /review first, or review was started in current session mode)",
                    "info",
                );
            }
            return;
        }

        endReviewInProgress = true;
        try {
            const choice = await ctx.ui.select("Finish review:", [
                "Return only",
                "Return and fix findings",
                "Return and summarize",
            ]);

            if (choice === undefined) {
                ctx.ui.notify("Cancelled. Use /end-review to try again.", "info");
                return;
            }

            const action: EndReviewAction =
                choice === "Return and fix findings"
                    ? "returnAndFix"
                    : choice === "Return and summarize"
                        ? "returnAndSummarize"
                        : "returnOnly";

            if (action === "returnOnly") {
                try {
                    const result = await ctx.navigateTree(originId, { summarize: false });
                    if (result.cancelled) {
                        ctx.ui.notify("Navigation cancelled. Use /end-review to try again.", "info");
                        return;
                    }
                } catch (error) {
                    ctx.ui.notify(`Failed to return: ${error instanceof Error ? error.message : String(error)}`, "error");
                    return;
                }

                clearReviewState(ctx);
                ctx.ui.notify("Review complete! Returned to original position.", "info");
                return;
            }

            const summaryResult = await ctx.ui.custom<{ cancelled: boolean; error?: string } | null>((tui, theme, _kb, done) => {
                const loader = new BorderedLoader(tui, theme, "Returning and summarizing review branch...");
                loader.onAbort = () => done(null);

                ctx.navigateTree(originId, {
                    summarize: true,
                    customInstructions: REVIEW_SUMMARY_PROMPT,
                    replaceInstructions: true,
                })
                    .then(done)
                    .catch((err) => done({ cancelled: false, error: err instanceof Error ? err.message : String(err) }));

                return loader;
            });

            if (summaryResult === null) {
                ctx.ui.notify("Summarization cancelled. Use /end-review to try again.", "info");
                return;
            }

            if (summaryResult.error) {
                ctx.ui.notify(`Summarization failed: ${summaryResult.error}`, "error");
                return;
            }

            if (summaryResult.cancelled) {
                ctx.ui.notify("Navigation cancelled. Use /end-review to try again.", "info");
                return;
            }

            clearReviewState(ctx);

            if (action === "returnAndSummarize") {
                if (!ctx.ui.getEditorText().trim()) {
                    ctx.ui.setEditorText("Act on the review findings");
                }
                ctx.ui.notify("Review complete! Returned and summarized.", "info");
                return;
            }

            pi.sendUserMessage(REVIEW_FIX_FINDINGS_PROMPT, { deliverAs: "followUp" });
            ctx.ui.notify("Review complete! Returned and queued a follow-up to fix findings.", "info");
        } finally {
            endReviewInProgress = false;
        }
    }

    // Register the /end-review command
    pi.registerCommand("end-review", {
        description: "Complete review and return to original position",
        handler: async (_args, ctx) => {
            await runEndReview(ctx);
        },
    });
}
