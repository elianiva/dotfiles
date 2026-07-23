/**
 * Bash tool override — interceptor + litmus description + runtime enforcement.
 *
 * Replaces the built-in bash tool with:
 * 1. A description that tells the LLM to use specialized tools, with litmus test
 * 2. Runtime interceptor that blocks commands shadowing dedicated tools
 * 3. Description adapts dynamically via getter based on active tools
 *
 * No renderCall/renderResult — built-in renderer is inherited automatically.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createBashToolDefinition } from "@earendil-works/pi-coding-agent";
import { INTERCEPT_RULES } from "./interceptor";

const BASE_DESCRIPTION = `Runs commands in a persistent shell session.

Litmus: one external-CLI call or short pipeline returning a count, frequency, set difference, or checksum -> bash.
Merely moves, pages, or trims bytes a tool can fetch -> use the specialized tool instead.

Commands shadowing specialized tools are BLOCKED at runtime.`;

export default function setupBashTool(pi: ExtensionAPI): void {
  const bash = createBashToolDefinition(process.cwd());

  pi.registerTool({
    name: "bash",
    label: "bash",
    description: BASE_DESCRIPTION,
    parameters: bash.parameters,
    promptSnippet: "Run real binaries and short fact pipelines",
    promptGuidelines: [
      "NEVER use bash for grep/rg/find/fd/cat/head/tail/sed -i/file writes — those have dedicated built-in tools. NON-NEGOTIABLE.",
      "Commands shadowing specialized tools are blocked at runtime.",
      "Litmus: external-CLI call or pipeline computing a count/frequency/diff -> bash. Moving/paging bytes -> specialized tool.",
    ],

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const command = (params.command as string).trim();

      for (const rule of INTERCEPT_RULES) {
        if (rule.re.test(command)) {
          return {
            content: [
              {
                type: "text",
                text: `BLOCKED: ${rule.message}\n\nOriginal command: ${command}`,
              },
            ],
            details: { blocked: true },
          };
        }
      }

      return bash.execute(toolCallId, params, signal, onUpdate, ctx);
    },
  });
}
