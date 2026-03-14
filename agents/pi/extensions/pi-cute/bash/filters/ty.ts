import { defineBashFilter } from "./define-filter";

export const tyFilter = defineBashFilter({
  name: "ty",
  description: "Compact ty type checker output — strip blank lines, keep errors",
  matchCommand: new RegExp("^ty\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Checking \\d+ file"),
      new RegExp("^ty \\d+\\.\\d+"),
    ],
    maxLines: 50,
    onEmpty: "ty: ok",
  },
});
