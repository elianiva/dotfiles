import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { createCodemodeTool } from "./src/codemode.js";
import { disposeAllExecutors } from "./src/executor-cache.js";

export default function registerCodemode(pi: ExtensionAPI) {
  pi.registerTool(createCodemodeTool());

  const activate = () => pi.setActiveTools(["codemode"]);

  pi.on("session_start", activate);
  pi.on("before_agent_start", async () => {
    activate();
    return undefined;
  });

  pi.on("session_shutdown", async () => {
    await disposeAllExecutors();
  });

  if (typeof process !== "undefined") {
    process.on("SIGINT", () => {
      void disposeAllExecutors();
    });
    process.on("SIGTERM", () => {
      void disposeAllExecutors();
    });
  }
}
