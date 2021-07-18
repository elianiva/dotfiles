local M = {}

M.plugin = {
  "jose-elias-alvarez/null-ls.nvim",
  config = function()
    require("plugins.null-ls").config()
  end,
}

M.config = function()
  local null_ls = require "null-ls"
  local b = null_ls.builtins

  vim.env.PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath "config" .. "/.prettierrc"

  null_ls.setup {
    debounce = 150,
    sources = {
      b.formatting.black,
      b.code_actions.gitsigns,
      b.formatting.stylua.with {
        args = {
          "--config-path",
          vim.fn.stdpath "config" .. "/stylua.toml",
          "-",
        },
      },
      b.formatting.prettierd.with {
        filetypes = {
          "typescriptreact",
          "typescript",
          "javascriptreact",
          "javascript",
          "svelte",
          "json",
          "jsonc",
          "css",
          "html",
        },
      },
    },
  }
end

return M
