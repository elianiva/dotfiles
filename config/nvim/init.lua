-- bootstrap impatient.nvim
vim.cmd [[
  let s:user = "lewis6991"
  let s:repo = "impatient.nvim"
  let s:install_path = stdpath("data") . "/site/pack/" . s:repo . "/start/" . s:repo
  if empty(glob(s:install_path)) > 0
    execute printf("!git clone --depth=1 https://github.com/%s/%s %s", s:user, s:repo, s:install_path)
    execute "packadd " .. s:repo
  endif
]]

require("impatient").enable_profile()

vim.cmd [[
  let s:user = "tani"
  let s:repo = "vim-jetpack"
  let s:install_path = stdpath("data") . "/site/pack/jetpack/start/" . s:repo
  if empty(glob(s:install_path)) > 0
    execute printf("!git clone --depth=1 https://github.com/%s/%s %s", s:user, s:repo, s:install_path)
    execute "packadd " .. s:repo
  endif
]]

require("deps")

-- optimise vim-jetpack
vim.g["jetpack#optimization"] = 2

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

vim.cmd [[ colorscheme gitgud_dark ]]
