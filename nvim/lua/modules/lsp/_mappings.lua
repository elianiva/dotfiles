local k = require("astronauta.keymap")
local nnoremap = k.nnoremap
local inoremap = k.inoremap

local M = {}

M.lsp_mappings = function(type)
  if type == "jdtls" then
    nnoremap { "<Leader>ga", require("jdtls").code_action, { silent = true } }
  else
    nnoremap { "<Leader>ga", require("plugins._telescope").code_actions, { silent = true } }
  end

  inoremap { "<C-s>", vim.lsp.buf.signature_help, { silent = true } }
  nnoremap { "K", vim.lsp.buf.hover, { silent = true } }
  nnoremap { "<Leader>gd", vim.lsp.buf.definition, { silent = true } }
  nnoremap { "<Leader>gt", "<CMD>LspTroubleToggle<CR>", { silent = true } }
  nnoremap {
    "<Leader>gD",
    function()
      vim.lsp.diagnostic.show_line_diagnostics {
        show_header = false,
        border = Util.borders
      }
    end,
    { silent = true },
  }
  nnoremap { "<Leader>gr", require("telescope.builtin").lsp_references, { silent = true } }
  nnoremap { "<Leader>gR", vim.lsp.buf.rename, { silent = true } }
  nnoremap {
    "<Leader>g]",
    function()
      vim.lsp.diagnostic.goto_next {
        popup_opts = {
          show_header = false,
          border = Util.borders
        }
      }
    end,
    { silent = true },
  }
  nnoremap {
    "<Leader>g[",
    function()
      vim.lsp.diagnostic.goto_prev {
        popup_opts = {
          show_header = false,
          border = Util.borders
        }
      }
    end,
    { silent = true },
  }
end

return M
