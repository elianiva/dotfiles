import { defineBashFilter } from "./define-filter";

export const mixFormatFilter = defineBashFilter({
  name: "mix-format",
  description: "Compact mix format output",
  matchCommand: new RegExp("^mix\\s+format(\\s|$)"),
  filters: {
    maxLines: 20,
    onEmpty: "mix format: ok",
  },
});
