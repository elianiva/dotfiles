local k = require"astronauta.keymap"
local nnoremap = k.nnoremap
local inoremap = k.inoremap
local snoremap = k.inoremap

local M = {}

-- vim-vsnip stuff
inoremap{
  '<C-j>',
  'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"',
  { silent = true, expr = true },
}
snoremap{
  '<C-j>',
  'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"',
  { silent = true, expr = true },
}
inoremap{
  '<C-k>',
  'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"',
  { silent = true, expr = true },
}
snoremap{
  '<C-k>',
  'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"',
  { silent = true, expr = true },
}

M.lsp_mappings = function()
  nnoremap{'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { silent = true }}
  nnoremap{'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { silent = true }}
  nnoremap{'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { silent = true }}
  inoremap{'<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { silent = true }}
  nnoremap{'gD', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', { silent = true }}
  nnoremap{'gr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', { silent = true }}
  nnoremap{'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', { silent = true }}
end

return M
