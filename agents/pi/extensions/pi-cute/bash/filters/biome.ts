import { defineBashFilter } from "./define-filter";

export const biomeFilter = defineBashFilter({
  name: "biome",
  description: "Compact Biome lint/format output — strip blank lines, keep diagnostics",
  matchCommand: new RegExp("^biome\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Checked \\d+ file"),
      new RegExp("^Fixed \\d+ file"),
      new RegExp("^The following command"),
      new RegExp("^Run it with"),
    ],
    maxLines: 50,
    onEmpty: "biome: ok",
  },
});
