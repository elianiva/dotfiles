import { defineBashFilter } from "./define-filter";

export const basedpyrightFilter = defineBashFilter({
  name: "basedpyright",
  description: "Compact basedpyright type checker output — strip blank lines, keep errors",
  matchCommand: new RegExp("^basedpyright\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Searching for source files"),
      new RegExp("^Found \\d+ source file"),
      new RegExp("^Pyright \\d+\\.\\d+"),
      new RegExp("^basedpyright \\d+\\.\\d+"),
    ],
    maxLines: 50,
    onEmpty: "basedpyright: ok",
  },
});
