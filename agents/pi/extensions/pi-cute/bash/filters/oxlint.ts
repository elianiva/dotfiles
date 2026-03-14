import { defineBashFilter } from "./define-filter";

export const oxlintFilter = defineBashFilter({
  name: "oxlint",
  description: "Compact oxlint output — strip blank lines, keep diagnostics",
  matchCommand: new RegExp("^oxlint\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Finished in \\d+"),
      new RegExp("^Found \\d+ warning"),
    ],
    maxLines: 50,
    onEmpty: "oxlint: ok",
  },
});
