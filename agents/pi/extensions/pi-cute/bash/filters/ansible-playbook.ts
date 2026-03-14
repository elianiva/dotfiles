import { defineBashFilter } from "./define-filter";

export const ansiblePlaybookFilter = defineBashFilter({
  name: "ansible-playbook",
  description: "Compact ansible-playbook output",
  matchCommand: new RegExp("^ansible-playbook\\b"),
  filters: {
    stripAnsi: true,
    stripLinesMatching: [
      new RegExp("^\\s*$"),
      new RegExp("^ok: \\["),
      new RegExp("^skipping: \\["),
    ],
    maxLines: 60,
  },
});
