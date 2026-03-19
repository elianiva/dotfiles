import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { registerGuardedBashTool } from "./bash/guarded-bash-tool";
// import { createRunTool } from "./codemode/executor.js";

export default function piCuteExtension(pi: ExtensionAPI) {
  registerGuardedBashTool(pi);

  // TODO: revisit in the future
  // const cwd = process.cwd();
  // pi.registerTool(createRunTool(cwd));
  // pi.on("session_start", async () => {
  //   pi.setActiveTools(["run"]);
  // });
}
