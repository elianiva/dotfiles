local k = require"astronauta.keymap"
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

M.lsp_mappings = function()
  inoremap{'<C-s>', vim.lsp.buf.signature_help, { silent = true }}
  nnoremap{'K', vim.lsp.buf.hover, { silent = true }}
  nnoremap{'ga', vim.lsp.buf.code_action, { silent = true }}
  nnoremap{'gd', vim.lsp.buf.definition, { silent = true }}
  nnoremap{'gD', vim.lsp.diagnostic.show_line_diagnostics, { silent = true }}
  nnoremap{'gr', require"telescope.builtin".lsp_references, { silent = true }}
  nnoremap{'gR', vim.lsp.buf.rename, { silent = true }}

  -- lspsaga stuff
  -- nnoremap{'ga', require"lspsaga.codeaction".code_action, { silent = true }}
  nnoremap{'<leader>gd', require"lspsaga.provider".preview_definition, { silent = true }}
  nnoremap{'gh', require"lspsaga.provider".lsp_finder, { silent = true }}
end

return M
