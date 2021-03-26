
local k = require("astronauta.keymap")
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

local hover = require("lspsaga.hover")
local signature = require("lspsaga.signaturehelp")
local rename = require("lspsaga.rename")
local diagnostic = require("lspsaga.diagnostic")
local provider = require("lspsaga.provider")

M.lsp_mappings = function(type)
  if type == "jdtls" then
    nnoremap({ "ga", require("jdtls").code_action, { silent = true } })
  else
    nnoremap({ "ga", require("plugins._telescope").code_actions, { silent = true } })
  end

  inoremap({ "<C-s>", signature.signature_help, { silent = true } })
  nnoremap({ "K", hover.render_hover_doc, { silent = true } })
  nnoremap({ "<leader>gd", provider.preview_definition, { silent = true } })
  nnoremap({ "gd", vim.lsp.buf.definition, { silent = true } })
  nnoremap({ "gD", diagnostic.show_line_diagnostics, { silent = true } })
  nnoremap({ "gr", require("telescope.builtin").lsp_references, { silent = true } })
  nnoremap({ "gR", rename.rename, { silent = true } })
  nnoremap({ "gh", provider.lsp_finder, { silent = true } })
  nnoremap({ "<Leader>dn", diagnostic.lsp_jump_diagnostic_next, { silent = true } })
  nnoremap({ "<Leader>dN", diagnostic.lsp_jump_diagnostic_prev, { silent = true } })
end

return M
