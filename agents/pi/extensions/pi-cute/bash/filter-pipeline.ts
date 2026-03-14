import { applyBashCommandFilters } from "./filters";

export function filterCommandOutput(commandInput: string, output: string): string {
  try {
    return applyBashCommandFilters(commandInput, output);
  } catch {
    return output;
  }
}
