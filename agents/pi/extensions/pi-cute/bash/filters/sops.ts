import { defineBashFilter } from "./define-filter";

export const sopsFilter = defineBashFilter({
  name: "sops",
  description: "Compact sops output",
  matchCommand: new RegExp("^sops\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    maxLines: 40,
  },
});
