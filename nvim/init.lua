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

-- order matters
vim.cmd [[
  runtime! lua/modules/keymap.lua
  runtime! lua/modules/options.lua
  runtime! lua/modules/util.lua
  runtime! lua/modules/mappings.lua
  runtime! lua/modules/statusline.lua
]]
