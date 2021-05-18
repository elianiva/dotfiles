vim.cmd([[packadd formatter.nvim]])

local k = require("astronauta.keymap")
local nnoremap = k.nnoremap
vim.env.PRETTIERD_DEFAULT_CONFIG = "~/.config/nvim/.prettierrc"

local prettier = function()
  return {
    exe = "prettierd",
    args = {
      vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))
    },
    stdin = true,
  }
end

-- local denofmt = function()
--   return {
--     exe = "deno",
--     args = { "fmt", "-" },
--     stdin = true,
--   }
-- end

local rustfmt = function()
  return {
    exe = "rustfmt",
    args = { "--emit=stdout" },
    stdin = true,
  }
end

local dartfmt = function()
  return {
    exe = "dartfmt",
    args = { "--fix" },
    stdin = true,
  }
end

local gofmt = function()
  return {
    exe = "gofumpt",
    stdin = true,
  }
end

local stylua = function()
  return {
    exe = "stylua",
    args = {
      "--config-path",
      "~/.config/nvim/.stylua",
      "-"
    },
    stdin = true,
  }
end

require("formatter").setup({
  logging = true,
  filetype = {
    typescriptreact = { prettier },
    javascriptreact = { prettier },
    javascript = { prettier },
    typescript = { prettier },
    svelte     = { prettier },
    css        = { prettier },
    jsonc      = { prettier },
    json       = { prettier },
    html       = { prettier },
    php        = { prettier },
    rust       = { rustfmt },
    go         = { gofmt },
    lua        = { stylua },
    dart       = { dartfmt },
  },
})

nnoremap { "<Leader>gf", "<CMD>Format<CR>", { silent = true } }
