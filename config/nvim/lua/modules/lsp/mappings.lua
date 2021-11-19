local k = vim.keymap
local nnoremap = k.nnoremap
local inoremap = k.inoremap
local vnoremap = k.vnoremap
local telescope = require "telescope.builtin"

local M = {}

M.lsp_mappings = function()
  inoremap { "<C-s>", vim.lsp.buf.signature_help, { silent = true } }
  nnoremap { "K", vim.lsp.buf.hover, { silent = true } }
  nnoremap { "<Leader>ga", vim.lsp.buf.code_action, { silent = true } }
  nnoremap { "<Leader>gf", vim.lsp.buf.formatting_seq_sync, { silent = true } }
  vnoremap { "<Leader>gf", vim.lsp.buf.range_formatting, { silent = true } }
  nnoremap { "<Leader>gd", vim.lsp.buf.definition, { silent = true } }
  nnoremap { "<Leader>gl", vim.lsp.codelens.run, { silent = true } }
  nnoremap {
    "<Leader>gD",
    function()
      vim.diagnostic.open_float(0, {
        show_header = false,
        border = Util.borders,
        severity_sort = true,
        scope = "line",
      })
    end,
    { silent = true },
  }
  nnoremap { "<Leader>gr", telescope.lsp_references, { silent = true } }
  nnoremap { "<Leader>gR", vim.lsp.buf.rename, { silent = true } }
  nnoremap {
    "<Leader>g]",
    function()
      vim.diagnostic.goto_next {
        float = {
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
      vim.diagnostic.goto_prev {
        float = {
          show_header = false,
          border = Util.borders,
        },
      }
    end,
    { silent = true },
  }
end

return M
