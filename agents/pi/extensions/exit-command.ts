import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    // Only handle plain "exit" without arguments
    if (event.text.trim() === "exit") {
      ctx.shutdown();
      return { action: "handled" };
    }

    return { action: "continue" };
  });
}
