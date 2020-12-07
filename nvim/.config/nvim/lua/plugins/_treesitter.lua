local treesitter_config = require("nvim-treesitter.configs")
local treesitter_parser = require"nvim-treesitter.parsers".get_parser_configs()

-- treesitter_parser.svelte = {
--   install_info = {
--     url = "~/repos/tree-sitter-svelte",
--     files = {"src/parser.c", "src/scanner.cc"}
--   },
--   filetype = "svelte",
-- }

treesitter_config.setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "jsdoc",
    "fennel",
    "html",
    "php",
    "rust",
    "tsx",
    "python",
    "lua",
    "yaml",
  },

  highlight = {
    enable = true,
    disable = {'svelte'},
    use_languagetree = true,
  },

  indent = {
    enable = true
  },
}
