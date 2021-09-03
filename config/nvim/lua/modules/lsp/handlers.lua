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

local on_publish_diagnostics = function(_, _, params, client_id, _, config)
  local uri = params.uri
  local bufnr = vim.uri_to_bufnr(uri)

  if not bufnr then
    return
  end

  local diagnostics = params.diagnostics

  vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  -- don't mutate the original diagnostic because it would interfere with
  -- code action (and probably other stuff, too)
  local prefixed_diagnostics = vim.deepcopy(diagnostics)
  for i, v in pairs(diagnostics) do
    prefixed_diagnostics[i].message = string.format(
      "%s: %s",
      v.source,
      v.message
    )
  end
  vim.lsp.diagnostic.display(prefixed_diagnostics, bufnr, client_id, config)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  on_publish_diagnostics,
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

local signs = {
  Error = " ",
  Warning = " ",
  Hint = " ",
  Information = " ",
}

for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
