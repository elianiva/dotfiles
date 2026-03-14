import { defineBashFilter } from "./define-filter";

export const swiftBuildFilter = defineBashFilter({
  name: "swift-build",
  description: "Compact swift build output — short-circuit on success, strip Compiling/Linking",
  matchCommand: new RegExp("^swift\\s+build\\b"),
  filters: {
    stripAnsi: true,
    matchOutput: [
      {
        pattern: new RegExp("Build complete!"),
        message: "ok (build complete)",
        unless: new RegExp("warning:|error:"),
      },
    ],
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^Compiling "),
      new RegExp("^Linking "),
    ],
    maxLines: 40,
  },
});
