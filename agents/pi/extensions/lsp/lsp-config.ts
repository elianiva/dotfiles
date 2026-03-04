/**
 * LSP Server Configurations
 *
 * Each server defines:
 * - id: Unique identifier
 * - extensions: File extensions this server handles
 * - root: Function to find project root directory
 * - spawn: Function to start the LSP server process
 */

import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { access, constants } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { homedir } from "node:os";

// Mason bin path (Neovim plugin manager)
const MASON_BIN_PATH = resolve(homedir(), ".local/share/nvim/mason/bin");

export interface LspHandle {
  process: ChildProcessWithoutNullStreams;
  initialization?: Record<string, unknown>;
}

export type RootFunction = (file: string, cwd: string) => Promise<string | undefined>;

export interface LspServerInfo {
  id: string;
  extensions: string[];
  root: RootFunction;
  spawn(root: string, cwd: string): Promise<LspHandle | undefined>;
}

// Language ID mapping for LSP
export const LANGUAGE_MAP: Record<string, string> = {
  ".ts": "typescript",
  ".tsx": "typescriptreact",
  ".js": "javascript",
  ".jsx": "javascriptreact",
  ".mjs": "javascript",
  ".cjs": "javascript",
  ".mts": "typescript",
  ".cts": "typescript",
  ".lua": "lua",
  ".py": "python",
  ".pyi": "python",
  ".rs": "rust",
  ".php": "php",
  ".svelte": "svelte",
  ".astro": "astro",
  ".vue": "vue",
  ".css": "css",
  ".scss": "scss",
  ".less": "less",
  ".html": "html",
  ".json": "json",
  ".jsonc": "json",
  ".yaml": "yaml",
  ".yml": "yaml",
  ".md": "markdown",
  ".typ": "typst",
  ".typc": "typst",
  ".go": "go",
  ".zig": "zig",
  ".zon": "zig",
  ".c": "c",
  ".cpp": "cpp",
  ".cc": "cpp",
  ".cxx": "cpp",
  ".c++": "cpp",
  ".h": "c",
  ".hpp": "cpp",
  ".hh": "cpp",
  ".hxx": "cpp",
  ".h++": "cpp",
  ".ex": "elixir",
  ".exs": "elixir",
  ".cs": "csharp",
  ".fs": "fsharp",
  ".fsi": "fsharp",
  ".fsx": "fsharp",
  ".fsscript": "fsharp",
  ".swift": "swift",
  ".kt": "kotlin",
  ".kts": "kotlin",
  ".java": "java",
  ".rb": "ruby",
  ".rake": "ruby",
  ".dart": "dart",
  ".ml": "ocaml",
  ".mli": "ocaml",
  ".sh": "shellscript",
  ".bash": "shellscript",
  ".zsh": "shellscript",
  ".ksh": "shellscript",
  ".nix": "nix",
  ".gleam": "gleam",
  ".clj": "clojure",
  ".cljs": "clojure",
  ".cljc": "clojure",
  ".edn": "clojure",
  ".hs": "haskell",
  ".lhs": "haskell",
  ".jl": "julia",
  ".tf": "terraform",
  ".tfvars": "terraform",
  ".tex": "latex",
  ".bib": "latex",
  ".prisma": "prisma",
};

/**
 * Check if a path exists (async)
 */
async function pathExists(path: string): Promise<boolean> {
  try {
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

/**
 * Find binary in PATH, checking Mason bin first
 */
export async function which(bin: string): Promise<string | undefined> {
  // 1. Check Mason bin first (Neovim LSP servers)
  const masonPath = resolve(MASON_BIN_PATH, bin);
  if (await pathExists(masonPath)) return masonPath;

  // 2. Check PATH
  const pathEnv = process.env.PATH || "";
  for (const dir of pathEnv.split(":")) {
    if (!dir) continue;
    const fullPath = resolve(dir, bin);
    if (await pathExists(fullPath)) return fullPath;
  }

  return undefined;
}

/**
 * Helper to find nearest file upward in directory tree
 */
export function nearestRoot(includePatterns: string[], excludePatterns?: string[]): RootFunction {
  return async (file: string, cwd: string) => {
    let current = dirname(file);
    const stopAt = cwd;

    // Check for exclusions first
    if (excludePatterns) {
      while (current !== "/" && current !== dirname(current)) {
        for (const pattern of excludePatterns) {
          if (await pathExists(resolve(current, pattern))) {
            return undefined;
          }
        }
        if (current === stopAt) break;
        current = dirname(current);
      }
    }

    // Reset and check for inclusions
    current = dirname(file);
    while (current !== "/" && current !== dirname(current)) {
      for (const pattern of includePatterns) {
        if (await pathExists(resolve(current, pattern))) {
          return current;
        }
      }
      if (current === stopAt) break;
      current = dirname(current);
    }
    return undefined;
  };
}

/**
 * Create a simple spawn handle
 */
function createHandle(
  bin: string,
  args: string[],
  root: string,
  initialization?: Record<string, unknown>,
): LspHandle | undefined {
  const proc = spawn(bin, args, { cwd: root }) as ChildProcessWithoutNullStreams;
  return { process: proc, initialization };
}

// ============================================================================
// LSP Server Definitions
// ============================================================================

export const LSP_SERVERS: LspServerInfo[] = [
  // TypeScript/JavaScript
  {
    id: "typescript",
    extensions: [".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".mts", ".cts"],
    root: nearestRoot(
      [
        "package-lock.json",
        "bun.lockb",
        "bun.lock",
        "pnpm-lock.yaml",
        "yarn.lock",
        "package.json",
        "tsconfig.json",
      ],
      ["deno.json", "deno.jsonc"],
    ),
    async spawn(root, cwd) {
      // Try to find local tsserver first
      let tsserver: string | undefined;
      const possiblePaths = [
        resolve(cwd, "node_modules", "typescript", "lib", "tsserver.js"),
        resolve(root, "node_modules", "typescript", "lib", "tsserver.js"),
      ];
      for (const p of possiblePaths) {
        if (await pathExists(p)) {
          tsserver = p;
          break;
        }
      }

      const bin = await which("typescript-language-server");
      if (!bin) return undefined;

      return createHandle(
        bin,
        ["--stdio"],
        root,
        tsserver ? { tsserver: { path: tsserver } } : undefined,
      );
    },
  },

  // Deno
  {
    id: "deno",
    extensions: [".ts", ".tsx", ".js", ".jsx", ".mjs"],
    root: nearestRoot(
      ["deno.json", "deno.jsonc"],
      [
        "package-lock.json",
        "bun.lockb",
        "bun.lock",
        "pnpm-lock.yaml",
        "yarn.lock",
        "package.json",
        "tsconfig.json",
      ],
    ),
    async spawn(root) {
      const bin = await which("deno");
      if (!bin) return undefined;
      return createHandle(bin, ["lsp"], root);
    },
  },

  // Oxlint
  {
    id: "oxlint",
    extensions: [
      ".ts",
      ".tsx",
      ".js",
      ".jsx",
      ".mjs",
      ".cjs",
      ".mts",
      ".cts",
      ".json",
      ".jsonc",
      ".vue",
      ".astro",
      ".svelte",
      ".css",
    ],
    root: nearestRoot([
      ".oxlintrc.json",
      "package-lock.json",
      "bun.lockb",
      "bun.lock",
      "pnpm-lock.yaml",
      "yarn.lock",
      "package.json",
    ]),
    async spawn(root) {
      // Try local oxlint first
      let bin = resolve(root, "node_modules", ".bin", "oxlint");
      if (!(await pathExists(bin))) {
        bin = (await which("oxlint")) || "";
      }

      if (!bin || !(await pathExists(bin))) {
        // Try bun x oxlint
        const bunBin = (await which("bun")) || "bun";
        const proc = spawn(bunBin, ["x", "oxlint", "--lsp"], {
          cwd: root,
        }) as ChildProcessWithoutNullStreams;
        return { process: proc };
      }

      return createHandle(bin, ["--lsp"], root);
    },
  },

  // Rust
  {
    id: "rust",
    extensions: [".rs"],
    root: nearestRoot(["Cargo.toml", "Cargo.lock"]),
    async spawn(root) {
      const bin = await which("rust-analyzer");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // Go
  {
    id: "gopls",
    extensions: [".go"],
    root: nearestRoot(["go.work", "go.mod", "go.sum"]),
    async spawn(root) {
      const bin = await which("gopls");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // Python (Pyright)
  {
    id: "pyright",
    extensions: [".py", ".pyi"],
    root: nearestRoot([
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
    ]),
    async spawn(root) {
      let bin = await which("pyright-langserver");

      if (!bin) {
        // Try bun x
        const bunBin = (await which("bun")) || "bun";
        const proc = spawn(bunBin, ["x", "pyright", "--stdio"], {
          cwd: root,
        }) as ChildProcessWithoutNullStreams;
        return { process: proc };
      }

      const initialization: Record<string, string> = {};
      // Check for virtual env
      const venvPaths = [
        process.env.VIRTUAL_ENV,
        resolve(root, ".venv"),
        resolve(root, "venv"),
      ].filter(Boolean) as string[];

      for (const venvPath of venvPaths) {
        const pythonPath =
          process.platform === "win32"
            ? resolve(venvPath, "Scripts", "python.exe")
            : resolve(venvPath, "bin", "python");
        if (await pathExists(pythonPath)) {
          initialization.pythonPath = pythonPath;
          break;
        }
      }

      return createHandle(bin, ["--stdio"], root, initialization);
    },
  },

  // Lua
  {
    id: "lua",
    extensions: [".lua"],
    root: nearestRoot([
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      ".git",
    ]),
    async spawn(root) {
      const bin = await which("lua-language-server");
      if (!bin) return undefined;
      return createHandle(bin, [], root, { Lua: { diagnostics: { globals: ["vim"] } } });
    },
  },

  // PHP
  {
    id: "intelephense",
    extensions: [".php"],
    root: nearestRoot(["composer.json", "composer.lock", ".php-version"]),
    async spawn(root) {
      const bin = await which("intelephense");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root, { telemetry: { enabled: false } });
    },
  },

  // Svelte
  {
    id: "svelte",
    extensions: [".svelte"],
    root: nearestRoot([
      "package-lock.json",
      "bun.lockb",
      "bun.lock",
      "pnpm-lock.yaml",
      "yarn.lock",
      "package.json",
    ]),
    async spawn(root) {
      const bin = await which("svelteserver");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // Vue
  {
    id: "vue",
    extensions: [".vue"],
    root: nearestRoot([
      "package-lock.json",
      "bun.lockb",
      "bun.lock",
      "pnpm-lock.yaml",
      "yarn.lock",
      "package.json",
    ]),
    async spawn(root) {
      const bin = await which("vue-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // Astro
  {
    id: "astro",
    extensions: [".astro"],
    root: nearestRoot([
      "package-lock.json",
      "bun.lockb",
      "bun.lock",
      "pnpm-lock.yaml",
      "yarn.lock",
      "package.json",
    ]),
    async spawn(root, cwd) {
      const bin = await which("astro-ls");
      if (!bin) return undefined;

      // Find typescript for astro
      let tsdk: string | undefined;
      const possiblePaths = [
        resolve(cwd, "node_modules", "typescript", "lib"),
        resolve(root, "node_modules", "typescript", "lib"),
      ];
      for (const p of possiblePaths) {
        if (await pathExists(p)) {
          tsdk = p;
          break;
        }
      }

      return createHandle(bin, ["--stdio"], root, tsdk ? { typescript: { tsdk } } : undefined);
    },
  },

  // Zig
  {
    id: "zls",
    extensions: [".zig", ".zon"],
    root: nearestRoot(["build.zig", "build.zig.zon"]),
    async spawn(root) {
      const bin = await which("zls");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // C/C++
  {
    id: "clangd",
    extensions: [".c", ".cpp", ".cc", ".cxx", ".c++", ".h", ".hpp", ".hh", ".hxx", ".h++"],
    root: nearestRoot([
      "compile_commands.json",
      "compile_flags.txt",
      ".clangd",
      "CMakeLists.txt",
      "Makefile",
    ]),
    async spawn(root) {
      const bin = await which("clangd");
      if (!bin) return undefined;
      return createHandle(bin, ["--background-index", "--clang-tidy"], root);
    },
  },

  // C#
  {
    id: "csharp",
    extensions: [".cs"],
    root: nearestRoot([".slnx", ".sln", ".csproj", "global.json"]),
    async spawn(root) {
      const bin = (await which("csharp-ls")) || (await which("omnisharp"));
      if (!bin) return undefined;
      return createHandle(bin, ["-lsp"], root);
    },
  },

  // Swift
  {
    id: "sourcekit-lsp",
    extensions: [".swift"],
    root: nearestRoot(["Package.swift", "*.xcodeproj", "*.xcworkspace"]),
    async spawn(root) {
      const bin = await which("sourcekit-lsp");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // Elixir
  {
    id: "elixir-ls",
    extensions: [".ex", ".exs"],
    root: nearestRoot(["mix.exs", "mix.lock"]),
    async spawn(root) {
      const bin = (await which("elixir-ls")) || (await which("language_server.sh"));
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // Kotlin
  {
    id: "kotlin-ls",
    extensions: [".kt", ".kts"],
    root: nearestRoot([
      "settings.gradle.kts",
      "settings.gradle",
      "build.gradle.kts",
      "build.gradle",
      "pom.xml",
    ]),
    async spawn(root) {
      const bin = await which("kotlin-lsp");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // Dart
  {
    id: "dart",
    extensions: [".dart"],
    root: nearestRoot(["pubspec.yaml", "analysis_options.yaml"]),
    async spawn(root) {
      const bin = await which("dart");
      if (!bin) return undefined;
      return createHandle(bin, ["language-server", "--lsp"], root);
    },
  },

  // OCaml
  {
    id: "ocaml-lsp",
    extensions: [".ml", ".mli"],
    root: nearestRoot(["dune-project", "dune-workspace", ".merlin", "opam"]),
    async spawn(root) {
      const bin = await which("ocamllsp");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // Bash
  {
    id: "bash",
    extensions: [".sh", ".bash", ".zsh", ".ksh"],
    root: () => undefined, // Will use cwd
    async spawn(root) {
      const bin = await which("bash-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["start"], root);
    },
  },

  // Nix
  {
    id: "nixd",
    extensions: [".nix"],
    root: nearestRoot(["flake.nix", "flake.lock", ".git"]),
    async spawn(root) {
      const bin = await which("nixd");
      if (!bin) return undefined;
      return createHandle(bin, [], root);
    },
  },

  // YAML
  {
    id: "yaml",
    extensions: [".yaml", ".yml"],
    root: nearestRoot(["package.json"]),
    async spawn(root) {
      const bin = await which("yaml-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // JSON
  {
    id: "json",
    extensions: [".json", ".jsonc"],
    root: nearestRoot(["package.json"]),
    async spawn(root) {
      const bin = await which("vscode-json-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // HTML
  {
    id: "html",
    extensions: [".html"],
    root: nearestRoot(["package.json"]),
    async spawn(root) {
      const bin = await which("vscode-html-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // CSS
  {
    id: "css",
    extensions: [".css", ".scss", ".less"],
    root: nearestRoot(["package.json"]),
    async spawn(root) {
      const bin = await which("vscode-css-language-server");
      if (!bin) return undefined;
      return createHandle(bin, ["--stdio"], root);
    },
  },

  // Typst
  {
    id: "tinymist",
    extensions: [".typ", ".typc"],
    root: nearestRoot(["typst.toml"]),
    async spawn(root) {
      const bin = await which("tinymist");
      if (!bin) return undefined;
      return createHandle(bin, ["lsp"], root);
    },
  },

  // Terraform
  {
    id: "terraform",
    extensions: [".tf", ".tfvars"],
    root: nearestRoot([".terraform.lock.hcl", "terraform.tfstate", "*.tf"]),
    async spawn(root) {
      const bin = await which("terraform-ls");
      if (!bin) return undefined;
      return createHandle(bin, ["serve"], root);
    },
  },

  // Gleam
  {
    id: "gleam",
    extensions: [".gleam"],
    root: nearestRoot(["gleam.toml", "manifest.toml"]),
    async spawn(root) {
      const bin = await which("gleam");
      if (!bin) return undefined;
      return createHandle(bin, ["lsp"], root);
    },
  },

  // Clojure
  {
    id: "clojure-lsp",
    extensions: [".clj", ".cljs", ".cljc", ".edn"],
    root: nearestRoot(["deps.edn", "project.clj", "shadow-cljs.edn", "bb.edn", "build.boot"]),
    async spawn(root) {
      const bin = await which("clojure-lsp");
      if (!bin) return undefined;
      return createHandle(bin, ["listen"], root);
    },
  },

  // Haskell
  {
    id: "haskell-language-server",
    extensions: [".hs", ".lhs"],
    root: nearestRoot(["stack.yaml", "cabal.project", "hie.yaml", "*.cabal"]),
    async spawn(root) {
      const bin = await which("haskell-language-server-wrapper");
      if (!bin) return undefined;
      return createHandle(bin, ["--lsp"], root);
    },
  },

  // Julia
  {
    id: "julials",
    extensions: [".jl"],
    root: nearestRoot(["Project.toml", "Manifest.toml"]),
    async spawn(root) {
      const bin = await which("julia");
      if (!bin) return undefined;
      const proc = spawn(
        bin,
        ["--startup-file=no", "--history-file=no", "-e", "using LanguageServer; runserver()"],
        { cwd: root },
      ) as ChildProcessWithoutNullStreams;
      return { process: proc };
    },
  },

  // Prisma
  {
    id: "prisma",
    extensions: [".prisma"],
    root: nearestRoot(["schema.prisma", "prisma/schema.prisma"]),
    async spawn(root) {
      const bin = await which("prisma");
      if (!bin) return undefined;
      return createHandle(bin, ["language-server"], root);
    },
  },
];
