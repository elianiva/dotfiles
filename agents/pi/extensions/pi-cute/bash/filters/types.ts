import type { OutputFilters } from "../filter-engine";

export type BashFilterSpec = {
  name: string;
  description?: string;
  matchCommand: RegExp;
  filters: OutputFilters;
};
