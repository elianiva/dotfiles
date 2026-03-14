import { getWordText, word } from "../command-ast";
import { defineBashRewriter } from "./define-rewriter";

export const npmRewriter = defineBashRewriter({
  name: "npm",
  description: "Rewrite npm to detected package manager",
  rewriteCommand: (command, context) => {
    if (getWordText(command.name) !== "npm") return false;
    command.name = word(context.manager);
    return true;
  },
});
