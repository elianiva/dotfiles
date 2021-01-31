local k = require"astronauta.keymap"
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

-- local provider = require"lspsaga.provider"
local hover = require"lspsaga.hover"
local codeaction = require"lspsaga.codeaction"
local sig_help = require"lspsaga.signaturehelp"
local rename = require"lspsaga.rename"
local dianostic = require"lspsaga.diagnostic"

M.lsp_mappings = function()
  inoremap{'<C-s>', sig_help.signature_help, { silent = true }}
  nnoremap{'K', hover.render_hover_doc, { silent = true }}
  nnoremap{'ga', codeaction.code_action, { silent = true }}
  nnoremap{'gd', require"lspsaga.provider".preview_definition, { silent = true }}
  nnoremap{'<leader>gd', vim.lsp.buf.definition, { silent = true }}
  nnoremap{'gD', dianostic.show_line_diagnostics, { silent = true }}
  nnoremap{'gr', require"telescope.builtin".lsp_references, { silent = true }}
  nnoremap{'gR', rename.rename, { silent = true }}
  nnoremap{'gh', require"lspsaga.provider".lsp_finder, { silent = true }}
end

return M
