import { defineBashFilter } from "./define-filter";

export const jjFilter = defineBashFilter({
  name: "jj",
  description: "Compact Jujutsu (jj) output — strip blank lines, truncate",
  matchCommand: new RegExp("^jj\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Hint:"),
      new RegExp("^Working copy now at:"),
    ],
    truncateLinesAt: 120,
    maxLines: 30,
  },
});
