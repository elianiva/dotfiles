import { getWordText } from "../command-ast";
import { defineBashBlocker } from "./define-blocker";

const LINT_FORMAT_TOOLS = ["eslint", "prettier", "oxfmt", "stylelint", "oxlint"] as const;

export const directLintFormatBlocker = defineBashBlocker({
  name: "direct-lint-format",
  description: "Block direct lint/format tool execution",
  checkCommand: (command) => {
    const name = getWordText(command.name);
    return LINT_FORMAT_TOOLS.includes(name as any)
      ? `don't run '${name}' directly. use package.json script`
      : null;
  },
});
