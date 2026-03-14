import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { registerGuardedBashTool } from "./bash/guarded-bash-tool";

export default function piCuteExtension(pi: ExtensionAPI) {
  registerGuardedBashTool(pi);
}
