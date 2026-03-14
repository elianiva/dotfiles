import { defineBashFilter } from "./define-filter";

export const pingFilter = defineBashFilter({
  name: "ping",
  description: "Compact ping output — strip per-packet lines, keep summary",
  matchCommand: new RegExp("^ping\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^PING "),
      new RegExp("^Pinging "),
      new RegExp("^\\d+ bytes from "),
      new RegExp("^Reply from .+: bytes="),
      new RegExp("^\\s*$"),
    ],
    tailLines: 4,
  },
});
