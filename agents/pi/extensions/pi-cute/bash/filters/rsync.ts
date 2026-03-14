import { defineBashFilter } from "./define-filter";

export const rsyncFilter = defineBashFilter({
  name: "rsync",
  description: "Compact rsync output — short-circuit on success, strip progress",
  matchCommand: new RegExp("^rsync\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("total size is"),
        message: "ok (synced)",
        unless: new RegExp("error|failed|No such file"),
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^sending incremental file list"),
      new RegExp("^sent \\d"),
    ],
    maxLines: 20,
  },
});
