require("impatient").enable_profile()

vim.cmd [[
  let s:user = "wbthomason"
  let s:repo = "packer.nvim"
  let s:install_path = stdpath("data") . "/site/pack/packer/opt/" . s:repo
  if empty(glob(s:install_path)) > 0
    execute printf("!git clone https://github.com/%s/%s %s", s:user, s:repo, s:install_path)
    packadd repo
  endif
]]

-- map leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
runtime! lua/modules/util.lua
runtime! lua/modules/mappings.vim
runtime! lua/modules/statusline.lua
]]

local packer_cmd = function(name, cmd, opts)
  opts = opts or { force = true }
  vim.api.nvim_add_user_command(name, "packadd packer.nvim | " .. cmd, opts)
end

-- packer commands
packer_cmd("PackerInstall", "lua require('plugins.deps').install()")
packer_cmd("PackerUpdate", "lua require('plugins.deps').update()")
packer_cmd("PackerSync", "lua require('plugins.deps').sync()")
packer_cmd("PackerClean", "lua require('plugins.deps').clean()")
packer_cmd("PackerStatus", "lua require('plugins.deps').status()")
packer_cmd(
  "PackerCompile",
  "lua require('plugins.deps').compile('~/.config/nvim/plugin/packer_load.vim')"
)
packer_cmd(
  "PackerLoad",
  "packadd packer.nvim | lua require('packer').loader(<q-args>)",
  {
    force = true,
    nargs = "+",
    complete = "customlist,v:lua.require'packer'.loader_complete",
  }
)
