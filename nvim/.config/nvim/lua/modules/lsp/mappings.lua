local map = vim.api.nvim_buf_set_keymap
local telescope = require "telescope.builtin"

local M = {}

M.lsp_mappings = function(bufnr)
  map(bufnr, "i", "<C-s>", "", {
    callback = vim.lsp.buf.signature_help,
    desc = "Trigger signature help from the language server",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "K", vim.lsp.buf.hover, {
    desc = "Trigger hover window from the language server",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>ga", "", {
    callback = vim.lsp.buf.code_action,
    desc = "Pick code actions from the language server",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gf", "", {
    callback = vim.lsp.buf.formatting,
    desc = "Format current document",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gd", "", {
    callback = vim.lsp.buf.definition,
    desc = "Go to symbol definition",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gl", "", {
    callback = vim.lsp.codelens.run,
    desc = "Run codelens from the language server",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gD", "", {
    callback = function()
      vim.diagnostic.open_float(0, {
        show_header = false,
        border = Util.borders,
        severity_sort = true,
        scope = "line",
      })
    end,
    desc = "See diagnostics in floating window",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gr", "", {
    callback = telescope.lsp_references,
    desc = "Find symbol references using telescope",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gs", "", {
    callback = M.workspace_symbols,
    desc = "Find workspace symbols using Telescope",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>gR", "", {
    callback = vim.lsp.buf.rename,
    desc = "Rename current symbol",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>g]", "", {
    callback = function()
      vim.diagnostic.goto_next {
        float = { show_header = false, border = Util.borders },
      }
    end,
    desc = "Go to next diagnostic",
    noremap = true,
    silent = true,
  })

  map(bufnr, "n", "<Leader>g[", "", {
    callback = function()
      vim.diagnostic.goto_prev {
        float = { show_header = false, border = Util.borders },
      }
    end,
    desc = "Go to previous diagnostic",
    noremap = true,
    silent = true,
  })
end

return M
