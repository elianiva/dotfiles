vim.cmd[[packadd nvim-treesitter]]
vim.cmd[[packadd playground]]

local ts_config = require("nvim-treesitter.configs")

ts_config.setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "jsdoc",
    "fennel",
    "html",
    "php",
    "rust",
    "tsx",
    "cpp",
    "python",
    "lua",
    "yaml",
  },

  highlight = {
    enable = true,
    disable = { 'svelte' },
    use_languagetree = true,
  },

  indent = {
    enable = true
  },
}
