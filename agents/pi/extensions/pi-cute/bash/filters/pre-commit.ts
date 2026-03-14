import { defineBashFilter } from "./define-filter";

export const preCommitFilter = defineBashFilter({
  name: "pre-commit",
  description: "Compact pre-commit output",
  matchCommand: new RegExp("^pre-commit\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\[INFO\\] Installing environment"),
      new RegExp("^\\[INFO\\] Once installed this environment will be reused"),
      new RegExp("^\\[INFO\\] This may take a few minutes"),
      new RegExp("^\\s*$"),
    ],
    maxLines: 40,
  },
});
