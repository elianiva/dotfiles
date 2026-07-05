import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    if (event.text.trim() === "exit") {
      ctx.shutdown();
      return { handled: true };
    }

  });
}
