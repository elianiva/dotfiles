import { defineBashFilter } from "./define-filter";

export const jqFilter = defineBashFilter({
  name: "jq",
  description: "Compact jq output — truncate large JSON results",
  matchCommand: new RegExp("^jq\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    truncateLinesAt: 120,
    maxLines: 40,
  },
});
