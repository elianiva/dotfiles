local remap = vim.api.nvim_set_keymap

-- lsp actions
remap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
remap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
remap('n', 'gD', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', {noremap = true, silent = true})
remap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true})
remap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true, silent = true})

remap('i', '<Tab>', 'pumvisible() ? "<C-n>" : v:lua.check_backspace() ? "<Tab>" : completion#trigger_completion()', { noremap = true, expr = true })
remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })
