import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createProtocolReadTool } from "./read-tool";
import { createWebSearchTool } from "./tools/web-search";
import setupBashTool from "./tools/bash-tool";
import { setupWriteTool } from "./tools/write-tool";
import { setupEditTool } from "./tools/edit-tool";
import { setupGrepTool } from "./tools/grep-tool";
import { createPromptEnhancer } from "./prompt-enhancer";
import { createSubagentTool } from "./subagent/tool";

export default function (pi: ExtensionAPI): void {
  // Custom tools (not overriding built-ins)
  pi.registerTool(createProtocolReadTool());
  pi.registerTool(createWebSearchTool(pi));
  pi.registerTool(createSubagentTool(pi));

  // Override all built-in tools with enhanced descriptions
  setupWriteTool(pi);
  setupEditTool(pi);
  setupGrepTool(pi);
  // bash last — it includes the runtime interceptor
  setupBashTool(pi);

  // Inject "Specialized Tools" section + prompt files into system prompt
  createPromptEnhancer(pi);
}
