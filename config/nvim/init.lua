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
runtime! lua/modules/mappings.lua
runtime! lua/modules/statusline.lua
]]
