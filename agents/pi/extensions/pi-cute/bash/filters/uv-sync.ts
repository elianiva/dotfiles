import { defineBashFilter } from "./define-filter";

export const uvSyncFilter = defineBashFilter({
  name: "uv-sync",
  description: "Compact uv sync/pip install output — strip downloads, short-circuit when up-to-date",
  matchCommand: new RegExp("^uv\\s+(sync|pip\\s+install)\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("Audited \\d+ package"),
        message: "ok (up to date)",
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^\\s+Downloading "),
      new RegExp("^\\s+Using cached "),
      new RegExp("^\\s+Preparing "),
    ],
    maxLines: 20,
  },
});
