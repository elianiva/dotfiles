local fn, lsp = vim.fn, vim.lsp

lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
  border = Util.borders,
})

lsp.handlers["textDocument/signatureHelp"] = lsp.with(
  lsp.handlers.signature_help,
  {
    border = Util.borders,
  }
)

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    virtual_text = {
      prefix = "■ ",
      spacing = 4,
    },
    signs = true,
    update_in_insert = false,
  }
)

fn.sign_define {
  {
    name = "LspDiagnosticsSignError",
    text = "",
    texthl = "LspDiagnosticsSignError",
    linehl = "",
    numhl = "",
  },
  {
    name = "LspDiagnosticsSignWarning",
    text = "",
    texthl = "LspDiagnosticsSignWarning",
    linehl = "",
    numhl = "FooBar",
  },
  {
    name = "LspDiagnosticsSignInformation",
    text = "",
    texthl = "LspDiagnosticsSignInformation",
    linehl = "",
    numhl = "",
  },
  {
    name = "LspDiagnosticsSignHint",
    text = "",
    texthl = "LspDiagnosticsSignHint",
    linehl = "",
    numhl = "",
  },
}
