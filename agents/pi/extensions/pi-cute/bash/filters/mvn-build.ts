import { defineBashFilter } from "./define-filter";

export const mvnBuildFilter = defineBashFilter({
  name: "mvn-build",
  description: "Compact Maven build output",
  matchCommand: new RegExp("^mvn\\s+(compile|package|clean|install)\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\[INFO\\] ---"),
      new RegExp("^\\[INFO\\] Building\\s"),
      new RegExp("^\\[INFO\\] Downloading\\s"),
      new RegExp("^\\[INFO\\] Downloaded\\s"),
      new RegExp("^\\[INFO\\]\\s*$"),
      new RegExp("^\\s*$"),
      new RegExp("^Downloading:"),
      new RegExp("^Downloaded:"),
      new RegExp("^Progress"),
    ],
    maxLines: 50,
    onEmpty: "mvn: ok",
  },
});
