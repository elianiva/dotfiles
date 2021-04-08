local k = require("astronauta.keymap")
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

M.lsp_mappings = function(type)
  if type == "jdtls" then
    nnoremap({ "ga", require("jdtls").code_action, { silent = true } })
  else
    nnoremap({ "ga", require("plugins._telescope").code_actions, { silent = true } })
  end

  inoremap({ "<C-s>", vim.lsp.buf.signature_help, { silent = true } })
  nnoremap({ "K", vim.lsp.buf.hover, { silent = true } })
  nnoremap({ "gd", vim.lsp.buf.definition, { silent = true } })
  nnoremap({
    "gD",
    function()
      vim.lsp.diagnostic.show_line_diagnostics {
        border = Util.borders
      }
    end,
    { silent = true },
  })
  nnoremap({ "gr", require("telescope.builtin").lsp_references, { silent = true } })
  nnoremap({ "gR", vim.lsp.buf.rename, { silent = true } })
  nnoremap({
    "<Leader>dn",
    function()
      vim.lsp.diagnostic.goto_next { popup_opts = { border = Util.borders } }
    end,
    { silent = true },
  })
  nnoremap({
    "<Leader>dN",
    function()
      vim.lsp.diagnostic.goto_next { popup_opts = { border = Util.borders } }
    end,
    { silent = true },
  })
end

return M
