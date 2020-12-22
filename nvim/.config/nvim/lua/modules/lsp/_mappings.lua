local remap = vim.api.nvim_set_keymap
local M = {}

-- vim-vsnip stuff
remap('i', '<C-j>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"', { silent = true, expr = true })
remap('s', '<C-j>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"', { silent = true, expr = true })
remap('i', '<C-k>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"', { silent = true, expr = true })
remap('s', '<C-k>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"', { silent = true, expr = true })

M.lsp_mappings = function()
  remap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
  remap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  remap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
  remap('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, silent = true })
  remap('n', 'gD', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { noremap = true, silent = true })
  remap('n', 'gr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', { noremap = true, silent = true })
  remap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
  -- remap('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>', { noremap = true, silent = true })
end

return M
