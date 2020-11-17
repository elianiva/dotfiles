local remap = vim.api.nvim_set_keymap
local fn = vim.fn

-- local prettier = {{{{
--   {
--     cmd = {
--       function(file)
--         if not fn.empty(fn.glob(fn.getcwd() .. '/.prettierrc')) then
--           return string.format("prettier -w --config %s/.prettierrc '%s'", fn.getcwd(), file)
--         else
--           -- fallback to global config
--           return string.format("prettier -w --config ~/.config/nvim/.prettierrc '%s'", file)
--         end
--       end
--     },
--     tempfile_dir = os.getenv("HOME") .. "/.config/nvim"
--   }
-- }

-- local rustfmt = {
--   {
--     cmd = {'rustfmt'},
--     tempfile_dir = os.getenv("HOME") .. "/.config/nvim"
--   }
-- }

-- local luafmt = {
--   {
--     cmd = {
--       function(file)
--         return string.format("lua-format -i --config ~/.config/nvim/.luafmt '%s'", file)
--       end
--     },
--     tempfile_dir = os.getenv("HOME") .. "/.config/nvim"
--   }
-- }

-- require'format'.setup{
--   javascript = prettier,
--   typescript = prettier,
--   svelte = prettier,
--   html = prettier,
--   css = prettier,
--   rust = rustfmt,
--   lua = luafmt
-- }
-- remap('n', 'gf', '<cmd>FormatWrite<CR>', {noremap = true, silent = true})}}}

local prettier = function()
  if not fn.empty(fn.glob(fn.getcwd() .. '/.prettierrc')) then
    -- return string.format("prettier -w --config %s/.prettierrc '%s'", fn.getcwd(), file)
    return {
      exe = "prettier",
      args = {
        "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--config",
        vim.fn.getcwd() .. "/.prettierrc"
      },
      stdin = true
    }
  else
    -- fallback to global config
    return {
      exe = "prettier",
      args = {
        "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--config",
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
    svelte = {prettier},
    rust = {rustfmt},
    lua = {luafmt}
  }
}

remap('n', 'gf', '<CMD>Format<CR>', {silent = true, noremap = true})
