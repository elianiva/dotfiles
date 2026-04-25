import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { createCodemodeTool } from "./src/codemode.js";
import { disposeAllExecutors } from "./src/executor-cache.js";
import { createSandbox, disposeSandbox } from "./src/sandbox-cache.js";

export default function registerCodemode(pi: ExtensionAPI) {
  pi.registerTool(createCodemodeTool());

  const activate = () => pi.setActiveTools(["codemode"]);

  // Pre-warm sandbox on session start for current cwd
  pi.on("session_start", async (event, ctx) => {
    if (event.reason === "startup" || event.reason === "reload" || event.reason === "new") {
      const sandbox = await createSandbox(ctx.cwd);
      await disposeSandbox(sandbox);
    }
    // set active tools after sandbox is warmed
    activate();
  });

  pi.on("before_agent_start", async () => {
    activate();
    return undefined;
  });

  pi.on("session_shutdown", async () => {
    await disposeAllExecutors();
  });
}