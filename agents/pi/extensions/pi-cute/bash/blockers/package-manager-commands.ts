import { getWordText } from "../command-ast";
import { defineBashBlocker } from "./define-blocker";

const PACKAGE_MANAGERS = ["npm", "pnpm", "bun", "yarn", "npx", "bunx"] as const;
const LINT_FORMAT_TOOLS = ["eslint", "prettier", "oxfmt", "stylelint", "oxlint"] as const;
const DEV_BUILD_COMMANDS = ["dev", "build", "watch", "serve", "start"] as const;

export const packageManagerCommandsBlocker = defineBashBlocker({
  name: "package-manager-commands",
  description: "Block dev/build and direct lint invocations via package managers",
  checkCommand: (command) => {
    const name = getWordText(command.name);
    if (!PACKAGE_MANAGERS.includes(name as any)) return null;

    const args = (command.args ?? []).map(getWordText);

    const foundDev = args.find((a) => DEV_BUILD_COMMANDS.includes(a as any));
    if (foundDev) return `don't run '${foundDev}'. assume already running/succeeded`;

    const foundLint = args.find((a) => LINT_FORMAT_TOOLS.includes(a as any));
    if (foundLint) return `don't run '${foundLint}' directly. use package.json script`;

    return null;
  },
});
