import { defineBashFilter } from "./define-filter";

export const sshFilter = defineBashFilter({
  name: "ssh",
  description: "Compact ssh output — strip connection banners, keep command output",
  matchCommand: new RegExp("^ssh\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Warning: Permanently added"),
      new RegExp("^Connection to .+ closed"),
      new RegExp("^Authenticated to"),
      new RegExp("^debug1:"),
      new RegExp("^OpenSSH_"),
      new RegExp("^Pseudo-terminal"),
    ],
    truncateLinesAt: 120,
    maxLines: 200,
  },
});
