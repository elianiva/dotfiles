import { getWordText, word } from "../command-ast";
import { defineBashRewriter } from "./define-rewriter";

export const npxRewriter = defineBashRewriter({
  name: "npx",
  description: "Rewrite npx to bunx or pnpm dlx",
  rewriteCommand: (command, context) => {
    if (getWordText(command.name) !== "npx") return false;

    if (context.manager === "pnpm") {
      command.name = word("pnpm");
      command.args = [word("dlx"), ...(command.args ?? [])];
      return true;
    }

    command.name = word("bunx");
    return true;
  },
});
