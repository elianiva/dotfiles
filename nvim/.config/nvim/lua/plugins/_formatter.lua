vim.cmd[[packadd formatter.nvim]]

local remap = vim.api.nvim_set_keymap
local fn = vim.fn
local is_cfg_present = require('modules._util').is_cfg_present

local prettier = function()
  if is_cfg_present("/.prettierrc") then
    return {
      exe = "prettier",
      args = {
        string.format(
          "--stdin-filepath '%s' --config '%s'",
          vim.api.nvim_buf_get_name(0), vim.loop.cwd().."/.prettierrc"
        )
      },
      stdin = true
    }
  else
    -- fallback to global config
    return {
      exe = "prettier",
      args = {
        string.format(
          "--stdin-filepath '%s' --config '%s'",
          vim.api.nvim_buf_get_name(0), vim.fn.stdpath("config").."/.prettierrc"
        )
      },
      stdin = true
    }
  end
end

local rustfmt = function()
  return {exe = "rustfmt", args = {"--emit=stdout"}, stdin = true}
end

local gofmt = function()
  return {exe = "gofumpt", stdin = true}
end

local luafmt = function()
  return {
    exe = "lua-format",
    args = {"-i", "--config", "~/.config/nvim/.luafmt"},
    stdin = true
  }
end

require'formatter'.setup{
  logging = false,
  filetype = {
    javascript = {prettier},
    typescript = {prettier},
    typescriptreact = {prettier},
    svelte = {prettier},
    css = {prettier},
    jsonc = {prettier},
    json = {prettier},
    html = {prettier},
    php = {prettier},
    rust = {rustfmt},
    lua = {luafmt},
    go = {gofmt}
  }
}

remap('n', '<Leader>f', '<CMD>Format<CR>', {silent = true, noremap = true})
