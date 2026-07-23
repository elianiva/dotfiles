/**
 * Edit tool wrapper — steers the model toward edit instead of
 * sed/perl/awk -i in-place editing.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createEditToolDefinition } from "@earendil-works/pi-coding-agent";
import { wrapBuiltinTool } from "./wrap-builtin";

const CUSTOMIZATION = {
  description: `Edit a single file using exact text replacement. Every edits[].oldText must match a unique, non-overlapping region of the original file. When changing multiple separate locations, use one edit call with multiple entries in edits[].

Use this INSTEAD of: sed -i, perl -i, awk -i inplace.`,
  promptSnippet: "Make precise file edits with exact text replacement",
  promptGuidelines: [
    "Use edit for precise changes (edits[].oldText must match exactly)",
    "When changing multiple separate locations in one file, use one edit call with multiple entries in edits[] instead of multiple edit calls",
    "Each edits[].oldText is matched against the original file, not after earlier edits are applied. Do not emit overlapping or nested edits.",
    "Keep edits[].oldText as small as possible while still being unique in the file.",
  ],
};

export function setupEditTool(pi: ExtensionAPI): void {
  const edit = createEditToolDefinition(process.cwd());
  pi.registerTool(wrapBuiltinTool(edit, CUSTOMIZATION));
}
