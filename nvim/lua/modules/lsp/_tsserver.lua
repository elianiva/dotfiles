local ts_utils = require("nvim-lsp-ts-utils")

local M = {}

M.ts_utils = function(client)
  ts_utils.setup {
    eslint_bin = "eslint_d",
    eslint_args = { "-f", "json", "--stdin", "--stdin-filename", "$FILENAME" },
    eslint_enable_disable_comments = true,
    eslint_enable_diagnostics = true,
    eslint_diagnostics_debounce = 250,
    eslint_config_fallback = vim.fn.stdpath("config") .. "/.eslintrc.js"
  }
  ts_utils.setup_client(client)
end

M.config = {
  filetypes = {
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
  },
  init_options = {
    documentFormatting = false,
  },
  on_init = Util.lsp_on_init,
  on_attach = function(client)
    require("modules.lsp._mappings").lsp_mappings()
    require("lsp_signature").on_attach {
      bind = true,
      doc_lines = 2,
      hint_enable = false,
      handler_opts = {
        border = Util.borders,
      },
      max_height = 12,
      max_width = 120,
    }
    M.ts_utils(client)
  end,
  root_dir = vim.loop.cwd,
}

return M
