import { getWordText } from "../command-ast";
import { defineBashBlocker } from "./define-blocker";

export const rmRfBlocker = defineBashBlocker({
  name: "rm-rf",
  description: "Block rm -rf for safety",
  checkCommand: (command) => {
    if (getWordText(command.name) !== "rm") return null;

    let hasR = false;
    let hasF = false;
    for (const arg of command.args ?? []) {
      const text = getWordText(arg);
      if (text.startsWith("-") && !text.startsWith("--")) {
        if (text.toLowerCase().includes("r")) hasR = true;
        if (text.includes("f")) hasF = true;
      } else if (text === "--recursive") {
        hasR = true;
      } else if (text === "--force") {
        hasF = true;
      }
    }

    return hasR && hasF ? "rm -rf blocked for safety" : null;
  },
});
