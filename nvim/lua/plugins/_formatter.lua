vim.cmd([[packadd formatter.nvim]])

local is_cfg_present = require("modules._util").is_cfg_present
local k = require("astronauta.keymap")
local nnoremap = k.nnoremap

local prettier = function()
  if is_cfg_present("/.prettierrc") then
    return {
      exe = "prettier",
      args = {
        "--stdin-filepath",
        vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
        "--config",
        vim.loop.cwd() .. "/.prettierrc"
      },
      stdin = true,
    }
  end

  -- fallback to global config
  return {
    exe = "prettier",
    args = {
      "--stdin-filepath",
      vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)),
      "--config",
      vim.fn.stdpath("config") .. "/.prettierrc"
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
