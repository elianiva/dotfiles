import { defineBashFilter } from "./define-filter";

export const gccFilter = defineBashFilter({
  name: "gcc",
  description: "Compact gcc/g++ compiler output — strip notes, keep errors and warnings",
  matchCommand: new RegExp("^g(cc|\\+\\+)\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^\\s+\\|\\s*$"),
      new RegExp("^In file included from"),
      new RegExp("^\\s+from\\s"),
      new RegExp("^\\d+ warnings? generated"),
      new RegExp("^\\d+ errors? generated"),
    ],
    maxLines: 50,
    onEmpty: "gcc: ok",
  },
});
