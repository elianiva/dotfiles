import { defineBashFilter } from "./define-filter";

export const dotnetBuildFilter = defineBashFilter({
  name: "dotnet-build",
  description: "Compact dotnet build output — short-circuit on success, strip banners",
  matchCommand: new RegExp("^dotnet\\s+build\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("0 Warning\\(s\\)\\n\\s+0 Error\\(s\\)"),
        message: "ok (build succeeded)",
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Microsoft \\(R\\)"),
      new RegExp("^Copyright \\(C\\)"),
      new RegExp("^  Determining projects"),
    ],
    maxLines: 40,
  },
});
