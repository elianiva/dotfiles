local fn, lsp = vim.fn, vim.lsp

lsp.handlers["textDocument/hover"] = lsp.with(
  lsp.handlers.hover, {
    border = Util.borders
  }
)

lsp.handlers["textDocument/signatureHelp"] = lsp.with(
  lsp.handlers.signature_help, {
    border = Util.borders
  }
)

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    virtual_text = {
      prefix = "■ ",
      spacing = 4,
    },
    signs = true,
    update_in_insert = false,
  }
)

fn.sign_define(
  "LspDiagnosticsSignError",
  { text = "", texthl = "LspDiagnosticsDefaultError" }
)
fn.sign_define(
  "LspDiagnosticsSignWarning",
  { text = "", texthl = "LspDiagnosticsDefaultWarning" }
)
fn.sign_define(
  "LspDiagnosticsSignInformation",
  { text = "", texthl = "LspDiagnosticsDefaultInformation" }
)
fn.sign_define(
  "LspDiagnosticsSignHint",
  { text = "", texthl = "LspDiagnosticsDefaultHint" }
)
