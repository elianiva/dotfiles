require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "typescript",
    "javascript",
    "html",
    "java",
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
    use_languagetree = false,
    custom_captures = {
      ["variable"] = "Identifier",
      ["punctuation.delimiter"] = "Identifier"
    }
  },
}
