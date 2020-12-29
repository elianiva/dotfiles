vim.cmd[[packadd nvim-treesitter]]
vim.cmd[[packadd playground]]

local ts_config = require("nvim-treesitter.configs")
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.svelte = {
  install_info = {
    url = "~/repos/tree-sitter-html", -- local path or git repo
    files = {"src/parser.c", "src/scanner.cc"}
  },
  filetype = "svelte",
  used_by = {"svelte"}
}

ts_config.setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "jsdoc",
    "html",
    "css",
    "php",
    "rust",
    "tsx",
    "cpp",
    "python",
    "lua",
    "yaml",
    "toml",
    "go",
    "clojure",
    "fennel",
  },

  highlight = {
    enable = true,
    -- disable = { 'svelte' },
    use_languagetree = true,
  },

  indent = {
    enable = true
  },
}
