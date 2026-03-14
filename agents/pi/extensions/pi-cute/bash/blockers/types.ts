import type { AstCommand } from "../command-ast";

export type BashBlockContext = Record<string, never>;

export type BashBlockerSpec = {
  name: string;
  description?: string;
  checkCommand: (command: AstCommand, context: BashBlockContext) => string | null;
};
