require("modules.lsp")

require("rust-tools").setup {
  tools = {
    hover_actions = {
      border = Util.borders,
    },
  },
  server = {
    standalone = false,
    on_attach = Util.lsp_on_attach,
  },
}
