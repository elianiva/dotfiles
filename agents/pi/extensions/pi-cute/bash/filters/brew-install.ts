import { defineBashFilter } from "./define-filter";

export const brewInstallFilter = defineBashFilter({
  name: "brew-install",
  description: "Compact brew install/upgrade output — strip downloads, short-circuit when already installed",
  matchCommand: new RegExp("^brew\\s+(install|upgrade)\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("already installed"),
        message: "ok (already installed)",
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^==> Downloading"),
      new RegExp("^==> Pouring"),
      new RegExp("^Already downloaded:"),
      new RegExp("^###"),
      new RegExp("^==> Fetching"),
    ],
    maxLines: 20,
  },
});
