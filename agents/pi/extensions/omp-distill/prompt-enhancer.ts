/**
 * Injects oh-my-pi-derived system prompt enhancements into pi.
 *
 * Injections:
 * 1. Static markdown prompt files from prompts/ (delivery-contract, execution-workflow, etc.)
 * 2. Dynamic "Specialized Tools" section with per-tool mappings + litmus test
 * 3. Delegation strategy section when subagent tool is active
 */
import { readFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROMPTS_DIR = join(__dirname, "prompts");

interface PromptSection {
  name: string;
  content: string;
}

function loadPromptSections(): PromptSection[] {
  let files: string[];
  try {
    files = readdirSync(PROMPTS_DIR).filter((f) => f.endsWith(".md"));
  } catch {
    return [];
  }

  return files
    .sort()
    .map((file) => {
      const name = file.replace(/\.md$/, "");
      const fullPath = join(PROMPTS_DIR, file);
      try {
        const content = readFileSync(fullPath, "utf-8").trim();
        return content ? { name, content } : null;
      } catch {
        return null;
      }
    })
    .filter((p): p is PromptSection => p !== null);
}

/**
 * Build a "Specialized Tools" section that maps file operations to their
 * dedicated tools, with a litmus test for bash. Only includes mappings
 * for tools that are currently active.
 */
function buildSpecializedToolsSection(activeTools: string[]): string {
  const lines: string[] = [
    "# Specialized Tools",
    "",
    "You MUST use the specialized tool over its shell equivalent:",
  ];

  if (activeTools.includes("read")) {
    lines.push(
      "- File reads AND directory listing → `read` (NOT cat/head/tail/less/more, NOT ls in bash)",
    );
  }
  if (activeTools.includes("edit")) {
    lines.push("- Surgical text edits → `edit` (NOT sed/perl/awk -i)");
  }
  if (activeTools.includes("write")) {
    lines.push(
      "- Create or overwrite files → `write` (NOT echo/printf/cat redirections)",
    );
  }
  if (activeTools.includes("grep")) {
    lines.push(
      "- Regex/literal content search → `grep` (NOT grep/rg/ag/ack/awk)",
    );
  }
  if (activeTools.includes("glob")) {
    lines.push(
      "- File globbing → `glob` (NOT find/fd/locate or shell globs)",
    );
  }

  if (activeTools.includes("bash")) {
    lines.push("");
    lines.push(
      "Litmus test for bash: one external-CLI call or short pipeline returning a count, frequency, set difference, or checksum → bash. " +
        "Merely moves, pages, or trims bytes a tool can fetch → use the specialized tool.",
    );
    lines.push(
      "Commands shadowing the specialized tools above are BLOCKED at runtime.",
    );
  }

  return lines.join("\n");
}

export function createPromptEnhancer(pi: ExtensionAPI): void {
  const sections = loadPromptSections();
  const injectedStatic = sections.map((s) => s.content).join("\n\n");

  pi.on("before_agent_start", async (event) => {
    const activeTools = pi.getActiveTools();
    const specializedSection = buildSpecializedToolsSection(activeTools);
    let systemPrompt = event.systemPrompt;

    // Inject the "Specialized Tools" section (avoid double-injection)
    const specAnchor =
      "You MUST use the specialized tool over its shell equivalent";
    if (specializedSection && !systemPrompt.includes(specAnchor)) {
      systemPrompt = `${systemPrompt}\n\n${specializedSection}`;
    }

    // Inject static prompt files (avoid double-injection)
    if (injectedStatic) {
      const staticAnchor = injectedStatic.slice(0, 80);
      if (!systemPrompt.includes(staticAnchor)) {
        systemPrompt = `${systemPrompt}\n\n${injectedStatic}`;
      }
    }

    // Inject delegation strategy section if subagent tool is active
    if (activeTools.includes("subagent")) {
      const delegationAnchor = "Use `subagent` to parallelize independent work";
      const delegationSection = loadPromptSections().find((s) => s.name === "delegation-strategy");
      if (delegationSection && !systemPrompt.includes(delegationAnchor)) {
        systemPrompt = `${systemPrompt}\n\n${delegationSection.content}`;
      }
    }

    return { systemPrompt };
  });
}
