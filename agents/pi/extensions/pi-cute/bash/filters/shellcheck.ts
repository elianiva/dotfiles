import { defineBashFilter } from "./define-filter";

export const shellcheckFilter = defineBashFilter({
  name: "shellcheck",
  description: "Compact shellcheck output — strip blank lines, keep caret indicators for error position",
  matchCommand: new RegExp("^shellcheck\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    maxLines: 50,
  },
});
