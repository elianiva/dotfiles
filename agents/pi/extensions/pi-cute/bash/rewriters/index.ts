import type { BashAst } from "../command-ast";
import { parseCommand, serializeCommand, visitSimpleCommands } from "../command-ast";
import { grepRewriter } from "./grep";
import { npmRewriter } from "./npm";
import { npxRewriter } from "./npx";
import { pythonRewriter } from "./python";
import type { BashRewriteContext, BashRewriterSpec } from "./types";

export const BUILTIN_REWRITERS: BashRewriterSpec[] = [
  npmRewriter,
  npxRewriter,
  pythonRewriter,
  grepRewriter,
];

export function applyBashCommandRewriters(ast: BashAst, context: BashRewriteContext): boolean {
  let changed = false;

  visitSimpleCommands(ast, (command) => {
    for (const rewriter of BUILTIN_REWRITERS) {
      if (rewriter.rewriteCommand(command, context)) changed = true;
    }
  });

  return changed;
}

export function rewriteBashCommand(commandInput: string, context: BashRewriteContext): string {
  const ast = parseCommand(commandInput);
  const changed = applyBashCommandRewriters(ast, context);
  return changed ? serializeCommand(ast) : commandInput;
}
