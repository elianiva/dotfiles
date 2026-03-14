import { defineBashFilter } from "./define-filter";

export const statFilter = defineBashFilter({
  name: "stat",
  description: "Compact stat output — strip blank lines",
  matchCommand: new RegExp("^stat\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    maxLines: 30,
  },
});
