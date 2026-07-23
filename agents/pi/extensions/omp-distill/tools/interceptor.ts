/**
 * Bash interceptor rules — maps shell commands to their dedicated pi tools.
 *
 * Each rule has a regex to match the command, a help message, and the
 * target tool name. The interceptor only blocks when the substitute tool
 * is actually available in the current session.
 */
export interface InterceptRule {
  re: RegExp;
  message: string;
  /** Tool name to check availability against before blocking */
  tool: string;
}

export const INTERCEPT_RULES: InterceptRule[] = [
  {
    // grep/rg/ag/ack → grep tool
    re: /^\s*(grep|rg|ripgrep|ag|ack)\s+/,
    message:
      "Use the `grep` tool instead of grep/rg. It respects .gitignore and provides structured output.",
    tool: "grep",
  },
  {
    // cat/head/tail/less/more → read tool
    re: /^\s*(cat|head|tail|less|more)\s+/,
    message:
      "Use the `read` tool instead of cat/head/tail. It handles offsets, truncation, and binary files.",
    tool: "read",
  },
  {
    // ls → read (handles both files and directory listing)
    re: /^\s*ls\s+/,
    message:
      "Use `read` instead of ls. read handles both file contents and directory listing.",
    tool: "read",
  },
  {
    // find/fd/locate → glob tool (bare, with or without flags)
    re: /^\s*(find|fd|locate)\s+/,
    message:
      "Use the `glob` tool instead of find/fd. It respects .gitignore and is faster for glob patterns.",
    tool: "glob",
  },
  {
    // sed -i → edit tool
    re: /^\s*sed\s+(-i|--in-place)/,
    message:
      "Use the `edit` tool instead of sed -i. It provides diff preview and fuzzy matching.",
    tool: "edit",
  },
  {
    // perl -i → edit tool
    re: /^\s*perl\s+.*-[pn]?i/,
    message:
      "Use the `edit` tool instead of perl -i. It provides diff preview and fuzzy matching.",
    tool: "edit",
  },
  {
    // awk -i inplace → edit tool
    re: /^\s*awk\s+.*-i\s+inplace/,
    message:
      "Use the `edit` tool instead of awk -i inplace. It provides diff preview and fuzzy matching.",
    tool: "edit",
  },
  {
    // echo/printf/cat << redirections to files (not /dev/null etc.)
    re:
      /^\s*(echo|printf|cat\s*<<)\s+(?:(?:[^"'/>]|"[^"]*"|'[^']*')|(?<!\|)>{1,2}\|?\s*(?:"\/dev\/(?:null|tty|stdout|stderr)"|'\/dev\/(?:null|tty|stdout|stderr)'|\/dev\/(?:null|tty|stdout|stderr))(?:[\s;&|]|$))*(?<!\|)>{1,2}\|?\s*(?!(?:"\/dev\/(?:null|tty|stdout|stderr)"|'\/dev\/(?:null|tty|stdout|stderr)'|\/dev\/(?:null|tty|stdout|stderr))(?:[\s;&|]|$))[\w./~"'-]/,
    message:
      "Use the `write` tool instead of echo/cat redirection. It handles encoding and provides confirmation.",
    tool: "write",
  },
];
