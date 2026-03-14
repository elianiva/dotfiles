import { defineBashFilter } from "./define-filter";

export const hadolintFilter = defineBashFilter({
  name: "hadolint",
  description: "Compact hadolint Dockerfile linting output",
  matchCommand: new RegExp("^hadolint\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    truncateLinesAt: 120,
    maxLines: 40,
  },
});
