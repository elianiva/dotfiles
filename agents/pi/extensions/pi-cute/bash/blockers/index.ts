import { visitSimpleCommands, type BashAst } from "../command-ast";
import { directLintFormatBlocker } from "./direct-lint-format";
import { moonBlocker } from "./moon";
import { packageManagerCommandsBlocker } from "./package-manager-commands";
import { rmRfBlocker } from "./rm-rf";
import type { BashBlockContext, BashBlockerSpec } from "./types";

export const BUILTIN_BLOCKERS: BashBlockerSpec[] = [
  rmRfBlocker,
  moonBlocker,
  packageManagerCommandsBlocker,
  directLintFormatBlocker,
];

export function checkBlockedCommand(ast: BashAst, context: BashBlockContext = {}): string | null {
  let reason: string | null = null;

  visitSimpleCommands(ast, (command) => {
    if (reason) return;
    for (const blocker of BUILTIN_BLOCKERS) {
      reason = blocker.checkCommand(command, context);
      if (reason) return;
    }
  });

  return reason;
}
