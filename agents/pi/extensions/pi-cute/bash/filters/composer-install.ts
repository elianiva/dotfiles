import { defineBashFilter } from "./define-filter";

export const composerInstallFilter = defineBashFilter({
  name: "composer-install",
  description: "Compact composer install/update/require output — strip downloads, short-circuit when up-to-date",
  matchCommand: new RegExp("^composer\\s+(install|update|require)\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("Nothing to install, update or remove"),
        message: "ok (up to date)",
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^  - Downloading "),
      new RegExp("^  - Installing "),
      new RegExp("^Loading composer"),
      new RegExp("^Updating dependencies"),
    ],
    maxLines: 30,
  },
});
