/**
 * Bash tool override — litmus framing + soft steering toward specialized tools.
 *
 * No runtime interceptor: agents may use bash however they want. The
 * description and guidelines only point out that specialized tools exist
 * and are generally better for file operations.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createBashToolDefinition } from "@earendil-works/pi-coding-agent";
import { wrapBuiltinTool } from "./wrap-builtin";

const CUSTOMIZATION = {
  description: `Runs commands in a persistent shell session.

Specialized tools (read, edit, write, grep, find) exist for file operations and are generally better than their shell equivalents — prefer them when they fit.

Litmus: one external-CLI call or short pipeline returning a count, frequency, set difference, or checksum -> bash.
Merely moves, pages, or trims bytes a tool can fetch -> use the specialized tool instead.`,
  promptSnippet: "Run real binaries and short fact pipelines",
  promptGuidelines: [
    "Specialized tools (read, edit, write, grep, find) exist for file operations and are better than shell equivalents — prefer them, but bash works too.",
    "Litmus: external-CLI call or pipeline computing a count/frequency/diff -> bash. Moving/paging bytes -> specialized tool.",
  ],
};

export default function setupBashTool(pi: ExtensionAPI): void {
  const bash = createBashToolDefinition(process.cwd());
  pi.registerTool(wrapBuiltinTool(bash, CUSTOMIZATION));
}
