import { getWordText } from "../command-ast";
import { defineBashBlocker } from "./define-blocker";

const MOON_DEV_TARGET = /^(?:[^\s:]+:dev|:dev)$/;

export const moonBlocker = defineBashBlocker({
  name: "moon",
  description: "Block moon run *:dev and moon run :dev",
  checkCommand: (command) => {
    if (getWordText(command.name) !== "moon") return null;

    const args = (command.args ?? []).map(getWordText);
    if (args[0] !== "run") return null;

    const target = args.slice(1).find((arg) => MOON_DEV_TARGET.test(arg));
    return target ? `don't run '${target}'. assume already running/succeeded` : null;
  },
});
