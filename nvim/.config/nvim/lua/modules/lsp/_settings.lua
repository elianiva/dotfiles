vim.g.diagnostic_enable_virtual_text = 0
vim.g.diagnostic_virtual_text_prefix = '»'
vim.g.diagnostic_trimmed_virtual_text = 30

vim.call('sign_define', "LspDiagnosticsErrorSign", { text = "", texthl = "LspDiagnosticsError" })
vim.call('sign_define', "LspDiagnosticsWarningSign", { text = "", texthl = "LspDiagnosticsWarning" })
vim.call('sign_define', "LspDiagnosticsInformationSign", { text = "", texthl = "LspDiagnosticsInformation" })
vim.call('sign_define', "LspDiagnosticsHintSign", { text = "", texthl = "LspDiagnosticsHint" })
