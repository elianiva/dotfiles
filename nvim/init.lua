local g = vim.g
local packpath = vim.fn.stdpath("data") .. "/site/pack"

-- Ensures a given github.com/USER/REPO is cloned in the pack/packer/opt directory.
local ensure = function(user, repo)
  local install_path = string.format("%s/packer/opt/%s", packpath, repo, repo)
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd(string.format([[
        !git clone https://github.com/%s/%s %s
        packadd %s
    ]], user, repo, install_path, repo))
  end
end

-- Bootstrap essential plugins required for installing and loading the rest.
ensure("wbthomason", "packer.nvim")

-- map leader key to space
g.mapleader = " "
g.maplocalleader = " "

-- disable builtin plugins I don't use
g.loaded_gzip         = 1
g.loaded_tar          = 1
g.loaded_tarPlugin    = 1
g.loaded_zipPlugin    = 1
g.loaded_2html_plugin = 1
g.loaded_netrw        = 1
g.loaded_netrwPlugin  = 1
g.loaded_matchit      = 1
g.loaded_matchparen   = 1
g.loaded_spec         = 1

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
  cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
  cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- change cwd to current directory
vim.cmd [[cd %:p:h]]

-- order matters
local modules = {
  "modules._keymap",      -- keymap helpers
  "modules._settings",    -- `set` stuff
  "modules._util",        -- some useful utils
  "modules._mappings",    -- general mappings
  "modules._statusline",  -- my custom statusline
}

local errors = {}
for _, v in pairs(modules) do
  local ok, err = pcall(require, v)
  if not ok then
    table.insert(errors, err)
  end
end

if not vim.tbl_isempty(errors) then
  for _, v in pairs(errors) do
    print(v)
  end
end
