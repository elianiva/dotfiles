import { parse, serialize } from "just-bash";

export type AstWordPart = { type: string; value?: string };
export type AstWord = { type: "Word"; parts: AstWordPart[] };
export type AstCommand = { type: string; name?: AstWord; args?: AstWord[] };
export type AstPipeline = { commands?: AstCommand[] };
export type AstStatement = { type: string; pipelines?: AstPipeline[] };
export type BashAst = { statements?: AstStatement[] };

export function getWordText(word?: AstWord): string {
  if (!word || word.type !== "Word") return "";
  return word.parts.map((p) => (p.type === "Literal" ? (p.value ?? "") : "")).join("");
}

export function word(value: string): AstWord {
  return { type: "Word", parts: [{ type: "Literal", value }] };
}

export function parseCommand(command: string): BashAst {
  return parse(command) as unknown as BashAst;
}

export function serializeCommand(ast: BashAst): string {
  return serialize(ast as any);
}

export function visitSimpleCommands(ast: BashAst, visitor: (command: AstCommand) => void): void {
  for (const stmt of ast.statements ?? []) {
    if (stmt.type !== "Statement") continue;
    for (const pipe of stmt.pipelines ?? []) {
      for (const cmd of pipe.commands ?? []) {
        if (cmd.type !== "SimpleCommand") continue;
        visitor(cmd);
      }
    }
  }
}

