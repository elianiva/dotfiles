import { getWordText, word } from "../command-ast";
import { defineBashRewriter } from "./define-rewriter";

export const grepRewriter = defineBashRewriter({
  name: "grep",
  description: "Rewrite grep to rg with same args",
  rewriteCommand: (command) => {
    if (getWordText(command.name) !== "grep") return false;
    command.name = word("rg");
    return true;
  },
});
