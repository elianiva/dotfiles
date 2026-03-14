import { defineBashFilter } from "./define-filter";

export const psFilter = defineBashFilter({
  name: "ps",
  description: "Compact ps output — truncate wide lines, limit rows",
  matchCommand: new RegExp("^ps(\\s|$)"),
  filters: {
    stripAnsi: true,
    truncateLinesAt: 120,
    maxLines: 30,
  },
});
