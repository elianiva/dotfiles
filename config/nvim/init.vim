lua require("impatient").enable_profile()

let s:user = "wbthomason"
let s:repo = "packer.nvim"
let s:install_path = stdpath("data") . "/site/pack/packer/opt/" . s:repo
if empty(glob(s:install_path)) > 0
  execute printf("!git clone https://github.com/%s/%s %s", s:user, s:repo, s:install_path)
  packadd repo
endif

" map leader key to space
let g:mapleader = " "
let g:maplocalleader = " "

" disable filetype.vim
let g:did_load_filetypes = 1

" prevent typo when pressing `wq` or `q`
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))

" order matters
" runtime! lua/modules/keymap.lua
runtime! lua/modules/options.lua
runtime! lua/modules/util.lua
runtime! lua/modules/mappings.vim
runtime! lua/modules/statusline.lua

" packer commands
command! PackerInstall packadd packer.nvim | lua require('plugins.deps').install()
command! PackerUpdate  packadd packer.nvim | lua require('plugins.deps').update()
command! PackerSync    packadd packer.nvim | lua require('plugins.deps').sync()
command! PackerClean   packadd packer.nvim | lua require('plugins.deps').clean()
command! PackerStatus  packadd packer.nvim | lua require('plugins.deps').status()
command! PackerCompile packadd packer.nvim | lua require('plugins.deps').compile('~/.config/nvim/plugin/packer_load.vim')
command! -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad | lua require('packer').loader(<q-args>)
