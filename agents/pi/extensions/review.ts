/**
 * Simplified Code Review Extension
 *
 * Usage:
 * - `/review` - Review current working directory (snapshot)
 * - `/review from=<ref> to=<ref>` - Review diff between two commits/change IDs
 * - `/review last` - Review last commit (previous → current)
 *
 * Supports both jj and git. jj is preferred when available.
 */

import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import path from "node:path";
import { promises as fs } from "node:fs";

// Review mode types
type ReviewMode =
    | { type: "current" }
    | { type: "snapshot" }
    | { type: "diff"; from: string; to: string };

// VCS detection
async function getVCS(pi: ExtensionAPI, cwd: string): Promise<"jj" | "git" | null> {
    const { code: jjCode } = await pi.exec("jj", ["root"], { cwd });
    if (jjCode === 0) return "jj";

    const { code: gitCode } = await pi.exec("git", ["rev-parse", "--git-dir"], { cwd });
    if (gitCode === 0) return "git";

    return null;
}

// Get diff between two refs
async function getDiff(pi: ExtensionAPI, vcs: "jj" | "git", from: string, to: string, cwd: string): Promise<string> {
    if (vcs === "jj") {
        const { stdout, code } = await pi.exec("jj", ["diff", "--from", from, "--to", to], { cwd });
        if (code !== 0) throw new Error(`Failed to get jj diff from ${from} to ${to}`);
        return stdout;
    } else {
        const { stdout, code } = await pi.exec("git", ["diff", from, to], { cwd });
        if (code !== 0) throw new Error(`Failed to get git diff from ${from} to ${to}`);
        return stdout;
    }
}

// Get snapshot of current working directory
async function getSnapshot(pi: ExtensionAPI, vcs: "jj" | "git", cwd: string): Promise<string> {
    if (vcs === "jj") {
        // Get current change description and files
        const { stdout: desc, code: descCode } = await pi.exec("jj", ["describe", "--no-edit"], { cwd });
        const { stdout: status, code: statusCode } = await pi.exec("jj", ["status"], { cwd });

        if (descCode !== 0 || statusCode !== 0) {
            throw new Error("Failed to get jj status");
        }

        // Get diff of current changes
        const { stdout: diff, code: diffCode } = await pi.exec("jj", ["diff"], { cwd });

        return `Change: ${desc}\n\nStatus:\n${status}\n\n${diffCode === 0 ? diff : ""}`;
    } else {
        const { stdout: status, code: statusCode } = await pi.exec("git", ["status"], { cwd });
        const { stdout: diff, code: diffCode } = await pi.exec("git", ["diff", "HEAD"], { cwd });

        if (statusCode !== 0) {
            throw new Error("Failed to get git status");
        }

        return `Status:\n${status}\n\n${diffCode === 0 ? diff : ""}`;
    }
}

// Get previous commit reference (for "last" shortcut)
async function getPreviousRef(pi: ExtensionAPI, vcs: "jj" | "git", cwd: string): Promise<string> {
    if (vcs === "jj") {
        return "@-"; // jj parent shorthand
    } else {
        return "HEAD~1";
    }
}

// Get current commit reference
async function getCurrentRef(pi: ExtensionAPI, vcs: "jj" | "git", cwd: string): Promise<string> {
    if (vcs === "jj") {
        return "@"; // jj current change shorthand
    } else {
        return "HEAD";
    }
}

// Load project-specific review guidelines
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

// Review prompt template
const REVIEW_PROMPT = `You are a code reviewer. Review the code and provide findings organized into lists by category.

## What to flag
- Bugs, security issues, performance problems
- Maintainability issues (complexity, unclear names, missing tests)
- API design issues
- Issues introduced in the changes (not pre-existing)

## Output format
Provide findings as lists grouped by category. For each finding include:
- File location (\`path/to/file.ext:line\`)
- Brief explanation (1 sentence)
- Optional code suggestion (if simple fix)

Categories (only include if you have findings):

### Blocking Issues
Issues that must be fixed before merging (bugs, security, broken behavior).

### Warnings
Issues that should be addressed soon (performance concerns, error handling gaps, maintainability issues).

### Suggestions
Improvements that are nice to have (naming, style, minor simplifications).

If there are no issues in a category, omit that category. If everything looks good, say so explicitly.`;

// Parse command arguments
function parseArgs(args: string | undefined): ReviewMode | null | "help" {
    if (!args?.trim()) {
        return { type: "current" };
    }

    const parts = args.trim().split(/\s+/);
    const first = parts[0];

    // vcs snapshot
    if (first === "snapshot") {
        return { type: "snapshot" };
    }

    // Help
    if (first === "--help" || first === "-h") {
        return "help";
    }

    // "last" shortcut: previous → current
    if (first === "last" || first === "previous" || first === "prev") {
        return { type: "diff", from: "prev", to: "current" };
    }

    // Parse from= and to= params
    let from: string | null = null;
    let to: string | null = null;

    for (const part of parts) {
        if (part.startsWith("from=")) {
            from = part.slice(5);
        } else if (part.startsWith("to=")) {
            to = part.slice(3);
        }
    }

    if (from && to) {
        return { type: "diff", from, to };
    }

    // Shorthand: abc..def or abc...def
    if (first.includes("..")) {
        const [f, t] = first.split(/\.\.\.?/);
        if (f && t) {
            return { type: "diff", from: f, to: t };
        }
    }

    // Single arg: treat as from=arg to=current
    if (parts.length === 1 && !first.includes("=")) {
        return { type: "diff", from: first, to: "current" };
    }

    return null; // Invalid
}

export default function reviewExtension(pi: ExtensionAPI) {
    pi.registerCommand("review", {
        description: "Review code: /review [from=<ref> to=<ref> | last | <ref>..<ref>]",
        handler: async (args, ctx: ExtensionCommandContext) => {
            const parsed = parseArgs(args);

            if (parsed === "help") {
                pi.sendUserMessage(`Review command usage:
\`/review\` - Review current working directory (discover files yourself)
\`/review snapshot\` - Review VCS working directory snapshot
\`/review from=abc to=def\` - Review diff between refs
\`/review last\` - Review last commit (previous → current)
\`/review abc..def\` - Review diff shorthand
\`/review abc\` - Review from abc to current
Supports both jj (preferred) and git.`);
                return;
            }

            if (parsed === null) {
                ctx.ui.notify("Invalid review command. Use /review --help for usage.", "error");
                return;
            }

            const vcs = await getVCS(pi, ctx.cwd);
            if (!vcs) {
                ctx.ui.notify("No version control found (not a git or jj repository)", "error");
                return;
            }

            // Resolve "prev" and "current" shorthands
            let mode = parsed;
            if (mode.type === "diff") {
                let from = mode.from;
                let to = mode.to;

                if (from === "prev" || from === "previous") {
                    from = await getPreviousRef(pi, vcs, ctx.cwd);
                }
                if (to === "current") {
                    to = await getCurrentRef(pi, vcs, ctx.cwd);
                }

                mode = { type: "diff", from, to };
            }

            try {
                let content: string;
                let contextDesc: string;
                if (mode.type === "current") {
                    content = "Use available tools to discover and read files in the current working directory.";
                    contextDesc = "current working directory (discover files yourself)";
                } else if (mode.type === "snapshot") {
                    content = await getSnapshot(pi, vcs, ctx.cwd);
                    contextDesc = "VCS working directory";
                } else {
                    content = await getDiff(pi, vcs, mode.from, mode.to, ctx.cwd);
                    contextDesc = `diff from ${mode.from} to ${mode.to}`;
                }

                if (!content.trim()) {
                    ctx.ui.notify("No changes to review", "info");
                    return;
                }

                const guidelines = await loadProjectReviewGuidelines(ctx.cwd);

                let prompt = REVIEW_PROMPT;
                if (guidelines) {
                    prompt += `\n\n## Project Guidelines\n\n${guidelines}`;
                }

                prompt += `\n\n---\n\nReview the following ${contextDesc}:\n\n\`\`\`diff\n${content}\n\`\`\``;
                pi.sendUserMessage(prompt);
            } catch (error) {
                ctx.ui.notify(`Review failed: ${error instanceof Error ? error.message : String(error)}`, "error");
            }
        },
    });
}
