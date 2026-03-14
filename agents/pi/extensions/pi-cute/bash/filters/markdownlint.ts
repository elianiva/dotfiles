import { defineBashFilter } from "./define-filter";

export const markdownlintFilter = defineBashFilter({
  name: "markdownlint",
  description: "Compact markdownlint output — strip blank lines, limit rows",
  matchCommand: new RegExp("^markdownlint\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    truncateLinesAt: 120,
    maxLines: 50,
  },
});
