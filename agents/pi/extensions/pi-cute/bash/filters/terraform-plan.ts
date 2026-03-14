import { defineBashFilter } from "./define-filter";

export const terraformPlanFilter = defineBashFilter({
  name: "terraform-plan",
  description: "Compact Terraform plan output",
  matchCommand: new RegExp("^terraform\\s+plan"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^Refreshing state"),
      new RegExp("^\\s*#.*unchanged"),
      new RegExp("^\\s*$"),
      new RegExp("^Acquiring state lock"),
      new RegExp("^Releasing state lock"),
    ],
    maxLines: 80,
    onEmpty: "terraform plan: no changes detected",
  },
});
