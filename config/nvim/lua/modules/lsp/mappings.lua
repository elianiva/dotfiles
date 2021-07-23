local k = vim.keymap
local nnoremap = k.nnoremap
local inoremap = k.inoremap
local snoremap = k.snoremap
local telescope = require("telescope.builtin")

local M = {}

M.lsp_mappings = function()
  inoremap { "<C-s>", vim.lsp.buf.signature_help, { silent = true } }
  nnoremap { "K", vim.lsp.buf.hover, { silent = true } }
  nnoremap { "<Leader>ga", telescope.lsp_code_actions, { silent = true } }
  nnoremap { "<Leader>gf", vim.lsp.buf.formatting_seq_sync, { silent = true } }
  snoremap { "<Leader>gf", vim.lsp.buf.range_formatting, { silent = true } }
  nnoremap { "<Leader>gd", vim.lsp.buf.definition, { silent = true } }
  nnoremap { "<Leader>gl", vim.lsp.codelens.run, { silent = true } }
  nnoremap {
    "<Leader>gD",
    function()
      vim.lsp.diagnostic.show_line_diagnostics {
        show_header = false,
        border = Util.borders,
      }
    end,
    { silent = true },
  }
  nnoremap { "<Leader>gr", telescope.lsp_references, { silent = true } }
  nnoremap { "<Leader>gR", vim.lsp.buf.rename, { silent = true } }
  nnoremap {
    "<Leader>g]",
    function()
      vim.lsp.diagnostic.goto_next {
        popup_opts = {
          show_header = false,
          border = Util.borders,
        },
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
          border = Util.borders,
        },
      }
    end,
    { silent = true },
  }
end

return M
