import type { PackageManager } from "./package-manager";
import { rewriteBashCommand } from "./rewriters";

export function rewriteCommandInput(commandInput: string, manager: PackageManager): string {
  try {
    return rewriteBashCommand(commandInput, { manager });
  } catch {
    return commandInput;
  }
}
