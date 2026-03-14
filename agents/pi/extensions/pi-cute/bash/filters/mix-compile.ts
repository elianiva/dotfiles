import { defineBashFilter } from "./define-filter";

export const mixCompileFilter = defineBashFilter({
  name: "mix-compile",
  description: "Compact mix compile output",
  matchCommand: new RegExp("^mix\\s+compile(\\s|$)"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^Compiling \\d+ file"),
      new RegExp("^\\s*$"),
      new RegExp("^Generated\\s"),
    ],
    maxLines: 40,
    onEmpty: "mix compile: ok",
  },
});
