import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { createCodemodeTool } from "./src/codemode.js";
import { disposeAllExecutors, getExecutor } from "./src/executor-cache.js";
import { acquireSandbox, disposeAll as disposeAllSandboxes } from "./src/sandbox-cache.js";
import { initFinder } from "./src/fff.js";

export default function registerCodemode(pi: ExtensionAPI) {
  pi.registerTool(createCodemodeTool());

  const activate = () => pi.setActiveTools(["codemode"]);

  // Pre-warm sandbox, finder, and executor on session start
  pi.on("session_start", async (event, ctx) => {
    if (event.reason === "startup" || event.reason === "reload" || event.reason === "new") {
      await acquireSandbox(ctx.cwd);           // creates & caches sandbox
      initFinder(ctx.cwd).catch(() => {});     // fire-and-forget fff scan
      getExecutor(ctx.cwd).catch(() => {});    // fire-and-forget executor creation
    }
    activate();
  });

  pi.on("before_agent_start", async () => {
    activate();
    return undefined;
  });

  pi.on("session_shutdown", async () => {
    await Promise.allSettled([
      disposeAllExecutors(),
      disposeAllSandboxes(),
    ]);
  });
}
