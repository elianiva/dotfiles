import { defineBashFilter } from "./define-filter";

export const systemctlStatusFilter = defineBashFilter({
  name: "systemctl-status",
  description: "Compact systemctl status output — strip blank lines, limit to 20 lines",
  matchCommand: new RegExp("^systemctl\\s+status\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
    ],
    maxLines: 20,
  },
});
