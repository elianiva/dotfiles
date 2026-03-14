import { defineBashFilter } from "./define-filter";

export const makeFilter = defineBashFilter({
  name: "make",
  description: "Compact make output",
  matchCommand: new RegExp("^make\\b"),
  filters: {
    stripLinesMatching: [
      new RegExp("^make\\[\\d+\\]:"),
      new RegExp("^\\s*$"),
      new RegExp("^Nothing to be done"),
    ],
    maxLines: 50,
    onEmpty: "make: ok",
  },
});
