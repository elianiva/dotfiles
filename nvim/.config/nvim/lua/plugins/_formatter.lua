local remap = vim.api.nvim_set_keymap
local fn = vim.fn

local prettier = function()
  if not fn.empty(fn.glob(fn.getcwd() .. '/.prettierrc')) then
    return {
      exe = "prettier",
      args = {
        "--stdin-filepath", "'" .. vim.api.nvim_buf_get_name(0) .. "'", "--config",
        vim.fn.getcwd() .. "/.prettierrc"
      },
      stdin = true
    }
  else
    -- fallback to global config
    return {
      exe = "prettier",
      args = {
        "--stdin-filepath", "'" .. vim.api.nvim_buf_get_name(0) .. "'", "--config",
        "~/.config/nvim/.prettierrc"
      },
      stdin = true
    }
  end
end

local rustfmt = function()
  return {exe = "rustfmt", args = {"--emit=stdout"}, stdin = true}
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
    css = {prettier},
    html = {prettier},
    php = {prettier},
    svelte = {prettier},
    rust = {rustfmt},
    lua = {luafmt}
  }
}

remap('n', 'gf', '<CMD>Format<CR>', {silent = true, noremap = true})
