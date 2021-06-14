local null_ls = require("null-ls")
local h = require("null-ls.helpers")
local m = null_ls.methods
local b = null_ls.builtins

vim.env.PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath('config') .. "/.prettierrc"

local gofumpt = h.make_builtin {
  method = m.FORMATTING,
  filetypes = { "go" },
  generator_opts = {
    command = "gofumpt",
    to_stdin = true,
  },
  factory = h.formatter_factory,
}

local sources = {
  gofumpt,
  b.formatting.stylua.with {
    args = { "--config-path", vim.env.HOME.."/.config/nvim/stylua.toml", "-"},
  },
  b.formatting.prettierd.with {
    filetypes = {
      "typescriptreact", "typescript",
      "javascriptreact", "javascript",
      "svelte", "json", "jsonc", "css", "html",
    }
  }
}

null_ls.setup {
  sources = sources,
}
