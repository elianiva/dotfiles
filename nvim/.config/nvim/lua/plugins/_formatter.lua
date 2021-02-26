vim.cmd[[packadd formatter.nvim]]

local remap = vim.api.nvim_set_keymap
local is_cfg_present = require'modules._util'.is_cfg_present

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
    }
  end

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

local denofmt = function ()
  return { exe = "deno", args = "fmt", stdin = true }
end

local rustfmt = function()
  return {exe = "rustfmt", args = {"--emit=stdout"}, stdin = true}
end

local gofmt = function()
  return {exe = "gofumpt", stdin = true}
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
    go = {gofmt}
  }
}

remap('n', '<Leader>f', '<CMD>Format<CR>', {silent = true, noremap = true})
