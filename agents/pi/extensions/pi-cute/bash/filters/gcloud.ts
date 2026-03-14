import { defineBashFilter } from "./define-filter";

export const gcloudFilter = defineBashFilter({
  name: "gcloud",
  description: "Compact gcloud output",
  matchCommand: new RegExp("^gcloud\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    truncateLinesAt: 120,
    maxLines: 30,
  },
});
