vim.g.diagnostic_enable_virtual_text = 0
vim.g.diagnostic_virtual_text_prefix = '»'
vim.g.diagnostic_trimmed_virtual_text = 30

vim.fn.sign_define('LspDiagnosticsErrorSign', { text = "", texthl = "LspDiagnosticsError" })
vim.fn.sign_define('LspDiagnosticsWarningSign', { text = "", texthl = "LspDiagnosticsWarning" })
vim.fn.sign_define('LspDiagnosticsInformationSign', { text = "", texthl = "LspDiagnosticsInformation" })
vim.fn.sign_define('LspDiagnosticsHintSign', { text = "", texthl = "LspDiagnosticsHint" })
