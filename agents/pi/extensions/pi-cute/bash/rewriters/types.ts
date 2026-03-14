import type { AstCommand } from "../command-ast";
import type { PackageManager } from "../package-manager";

export type BashRewriteContext = {
  manager: PackageManager;
};

export type BashRewriterSpec = {
  name: string;
  description?: string;
  rewriteCommand: (command: AstCommand, context: BashRewriteContext) => boolean;
};
