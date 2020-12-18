vim.cmd[[packadd nvim-treesitter]]
vim.cmd[[packadd playground]]

local ts_config = require("nvim-treesitter.configs")
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.html.used_by = {"html", "svelte"}

ts_config.setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "jsdoc",
    "html",
    "php",
    "rust",
    "tsx",
    "cpp",
    "python",
    "lua",
    "yaml",
    "go",
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
