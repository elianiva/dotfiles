/**
 * Grep tool wrapper — steers the model toward the grep tool instead of
 * shelling out to grep/rg/ag/ack.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createGrepToolDefinition } from "@earendil-works/pi-coding-agent";
import { wrapBuiltinTool } from "./wrap-builtin";

const CUSTOMIZATION = {
  description: `Search file contents for patterns (regex or literal). Returns matching lines with file paths and line numbers. Respects .gitignore.

Use this INSTEAD of: grep, rg, ripgrep, ag, ack, awk (for search).`,
  promptSnippet: "Search file contents for patterns (use instead of grep/rg)",
  promptGuidelines: [
    "Use grep to search file contents instead of shelling out to grep/rg/awk.",
    "For file path lookup (not contents), use find/glob instead of find/fd.",
  ],
};

export function setupGrepTool(pi: ExtensionAPI): void {
  const grep = createGrepToolDefinition(process.cwd());
  pi.registerTool(wrapBuiltinTool(grep, CUSTOMIZATION));
}
