import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createProtocolReadTool } from "./read";
import { createWebSearchTool } from "./tools/web-search";
import setupBashTool from "./tools/bash-tool";
import { setupWriteTool } from "./tools/write-tool";
import { setupEditTool } from "./tools/edit-tool";
import { setupGrepTool } from "./tools/grep-tool";
import { createPromptEnhancer } from "./prompt-enhancer";
import { createSubagentTool } from "./subagent/tool";
import { createEvalTool } from "./tools/eval";
import { disposeJsSession } from "./tools/eval/vm";
import { disposePySession } from "./tools/eval/python/pool";
import { setupTtsr, resetTtsr } from "./ttsr";

export default function (pi: ExtensionAPI): void {
  // Custom tools (not overriding built-ins)
  pi.registerTool(createProtocolReadTool());
  pi.registerTool(createWebSearchTool(pi));
  pi.registerTool(createSubagentTool(pi));
  pi.registerTool(createEvalTool(pi));

  // Override all built-in tools with enhanced descriptions
  setupWriteTool(pi);
  setupEditTool(pi);
  setupGrepTool(pi);
  // bash last — stable ordering in the tools list
  setupBashTool(pi);

  // Inject behavioral prompt files into the system prompt
  createPromptEnhancer(pi);

  // Wire up TTSR hooks on session_start to get the correct cwd
  pi.on("session_start", (_event, ctx) => {
    setupTtsr(pi, ctx.cwd);
  });

  pi.on("session_shutdown", (_event, ctx) => {
    resetTtsr();
    const sessionId = ctx.sessionManager.getSessionId();
    if (sessionId) {
      void disposeJsSession(sessionId);
      void disposePySession(sessionId);
    }
  });
}
