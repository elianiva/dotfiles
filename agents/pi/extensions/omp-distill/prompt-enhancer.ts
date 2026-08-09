/**
 * Injects oh-my-pi-derived behavioral prompts into the system prompt.
 *
 * Injections:
 * 1. Static behavioral files from prompts/ (delivery-contract, execution-workflow,
 *    verification-rules) — the "delivery discipline" enumeration.
 * 2. Delegation strategy — only when the subagent tool is active.
 *
 * Tool-usage steering ("use read not cat", litmus test) is intentionally NOT
 * injected here: it lives in each tool's description and promptGuidelines,
 * plus the read tool's protocol documentation. No runtime enforcement —
 * agents may use bash however they want.
 */
import { readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROMPTS_DIR = join(__dirname, "prompts");

const STATIC_PROMPTS = ["delivery-contract", "execution-workflow", "verification-rules"];
const DELEGATION_PROMPT = "delegation-strategy";
const DELEGATION_ANCHOR = "Use `subagent` to parallelize independent work";

function loadPrompt(name: string): string | null {
  try {
    const content = readFileSync(join(PROMPTS_DIR, `${name}.md`), "utf-8").trim();
    return content || null;
  } catch {
    return null;
  }
}

export function createPromptEnhancer(pi: ExtensionAPI): void {
  const staticSections = STATIC_PROMPTS.map(loadPrompt)
    .filter((c): c is string => c !== null)
    .join("\n\n");
  const delegationSection = loadPrompt(DELEGATION_PROMPT);

  pi.on("before_agent_start", async (event) => {
    let systemPrompt = event.systemPrompt;

    // Inject behavioral prompts (avoid double-injection)
    if (staticSections && !systemPrompt.includes(staticSections.slice(0, 80))) {
      systemPrompt = `${systemPrompt}\n\n${staticSections}`;
    }

    // Inject delegation strategy only when the subagent tool is active
    if (
      delegationSection &&
      pi.getActiveTools().includes("subagent") &&
      !systemPrompt.includes(DELEGATION_ANCHOR)
    ) {
      systemPrompt = `${systemPrompt}\n\n${delegationSection}`;
    }

    return { systemPrompt };
  });
}
