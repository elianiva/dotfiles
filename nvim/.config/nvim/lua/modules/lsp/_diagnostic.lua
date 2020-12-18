vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = false,
  }
)

vim.fn.sign_define('LspDiagnosticsSignError', { text = "", texthl = "LspDiagnosticsDefaultError" })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = "", texthl = "LspDiagnosticsDefaultWarning" })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = "", texthl = "LspDiagnosticsDefaultInformation" })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = "", texthl = "LspDiagnosticsDefaultHint" })

-- custom diagnostic handling
vim.lsp.diagnostic.get_virtual_text_chunks_for_line = function(bufnr, line, line_diagnostics)
  if #line_diagnostics == 0 then
    return nil
  end

  local line_length = #(vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or '')
  local get_highlight = vim.lsp.diagnostic._get_severity_highlight_name

  -- Create a little more space between virtual text and contents
  local virt_texts = {{string.rep(" ", 10 - line_length)}}

  for i = 1, #line_diagnostics - 1 do
    table.insert(virt_texts, {"»", get_highlight(line_diagnostics[i].severity)})
  end
  local last = line_diagnostics[#line_diagnostics]

  if last.message then
    table.insert(
      virt_texts,
      {
        string.format("» %s", last.message:gsub("\r", ""):gsub("\n", "  ")),
        get_highlight(last.severity)
      }
    )

    return virt_texts
  end

  return virt_texts
end
