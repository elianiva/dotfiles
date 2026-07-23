/**
 * Write tool wrapper — steers the model toward write instead of
 * echo/printf/cat redirections.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createWriteToolDefinition } from "@earendil-works/pi-coding-agent";
import { wrapBuiltinTool } from "./wrap-builtin";

const CUSTOMIZATION = {
  description: `Create or overwrite files. Automatically creates parent directories.

Use this INSTEAD of: echo/printf/cat redirections (> or >>), tee.`,
  promptSnippet: "Create or overwrite files (use instead of echo/cat redirections)",
  promptGuidelines: [
    "Use write for creating or overwriting files instead of echo/cat redirection.",
  ],
};

export function setupWriteTool(pi: ExtensionAPI): void {
  const write = createWriteToolDefinition(process.cwd());
  pi.registerTool(wrapBuiltinTool(write, CUSTOMIZATION));
}
