import type { ToolDefinition } from "@earendil-works/pi-coding-agent";

export interface ToolCustomization {
  description: string;
  promptSnippet?: string;
  promptGuidelines?: string[];
}

/**
 * Wrap a built-in tool definition with custom description, promptSnippet,
 * and promptGuidelines while keeping its original execute(), parameters(),
 * renderers, and other runtime behavior.
 */
export function wrapBuiltinTool(
  builtin: ToolDefinition<any, any, any>,
  customization: ToolCustomization,
): ToolDefinition<any, any, any> {
  return {
    ...builtin,
    description: customization.description,
    ...(customization.promptSnippet !== undefined
      ? { promptSnippet: customization.promptSnippet }
      : {}),
    ...(customization.promptGuidelines !== undefined
      ? { promptGuidelines: customization.promptGuidelines }
      : {}),
  };
}
