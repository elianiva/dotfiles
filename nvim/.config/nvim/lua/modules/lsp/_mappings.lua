local k = require"astronauta.keymap"
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

-- local provider = require"lspsaga.provider"
local hover = require"lspsaga.hover"
local codeaction = require"lspsaga.codeaction"
local sig_help = require"lspsaga.signaturehelp"
local rename = require"lspsaga.rename"
local diagnostic = require"lspsaga.diagnostic"
local provider = require"lspsaga.provider"

M.lsp_mappings = function()
  inoremap{'<C-s>', sig_help.signature_help, { silent = true }}
  nnoremap{'K', hover.render_hover_doc, { silent = true }}
  nnoremap{'ga', codeaction.code_action, { silent = true }}
  -- nnoremap{'ga', vim.lsp.buf.code_action, { silent = true }}
  nnoremap{'gd', provider.preview_definition, { silent = true }}
  nnoremap{'<leader>gd', vim.lsp.buf.definition, { silent = true }}
  nnoremap{'gD', diagnostic.show_line_diagnostics, { silent = true }}
  nnoremap{'gr', require"telescope.builtin".lsp_references, { silent = true }}
  nnoremap{'gR', rename.rename, { silent = true }}
  nnoremap{'gh', provider.lsp_finder, { silent = true }}
  nnoremap{'<Leader>dn', diagnostic.lsp_jump_diagnostic_next, { silent = true }}
  nnoremap{'<Leader>dN', diagnostic.lsp_jump_diagnostic_prev, { silent = true }}

  -- nnoremap{
  --   '<C-y>',
  --   function()
  --     return hover.smart_scroll_hover(1)
  --   end,
  --   { silent = true },
  -- }
  -- nnoremap{
  --   '<C-e>',
  --   function()
  --     return hover.smart_scroll_hover(-1)
  --   end,
  --   { silent = true },
  -- }
end

return M
