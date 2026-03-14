import { defineBashFilter } from "./define-filter";

export const yamllintFilter = defineBashFilter({
  name: "yamllint",
  description: "Compact yamllint output — strip blank lines, limit rows",
  matchCommand: new RegExp("^yamllint\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    truncateLinesAt: 120,
    maxLines: 50,
  },
});
