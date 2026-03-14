import { getWordText, word } from "../command-ast";
import { defineBashRewriter } from "./define-rewriter";

const PYTHON_COMMANDS = ["python", "python3"] as const;

export const pythonRewriter = defineBashRewriter({
  name: "python",
  description: "Rewrite python invocations to uv run",
  rewriteCommand: (command) => {
    if (!PYTHON_COMMANDS.includes(getWordText(command.name) as any)) return false;
    command.name = word("uv");
    command.args = [word("run"), ...(command.args ?? [])];
    return true;
  },
});
