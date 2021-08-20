require("rust-tools").setup {
  tools = {
    inlay_hints = {
      show_parameter_hints = true,
      parameter_hints_prefix = "  <- ",
      other_hints_prefix = "  => ",
    },
    hover_actions = {
      border = Util.borders,
    },
  },
  server = {
    init_options = {
      detachedFiles = vim.fn.expand "%",
    },
    on_attach = Util.lsp_on_attach,
  },
}
