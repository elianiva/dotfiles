vim.g.diagnostic_enable_virtual_text = 0
vim.g.diagnostic_virtual_text_prefix = '»'
vim.g.diagnostic_insert_delay = 1

vim.fn.sign_define('LspDiagnosticsErrorSign', { text = "", texthl = "LspDiagnosticsError" })
vim.fn.sign_define('LspDiagnosticsWarningSign', { text = "", texthl = "LspDiagnosticsWarning" })
vim.fn.sign_define('LspDiagnosticsInformationSign', { text = "", texthl = "LspDiagnosticsInformation" })
vim.fn.sign_define('LspDiagnosticsHintSign', { text = "", texthl = "LspDiagnosticsHint" })

-- wait till TJ's big PR got merged
-- vim.lsp.handlers['textDcoument/publishDiagnostic'] = vim.lsp.with(
--   vim.lsp.diagnostic.on_publish_diagnostics, {
--     virtual_text = false,
--     signs = true,
--     update_in_insert = true,
--   }
-- )
