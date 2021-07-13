" Ensures a given github.com/USER/REPO is cloned in the pack/packer/opt directory.
function! Ensure(user, repo)
  let l:install_path = stdpath("data") . "/site/pack/packer/opt/" . a:repo
  if empty(glob(l:install_path)) > 0
    execute printf("!git clone https://github.com/%s/%s %s", a:user, a:repo, l:install_path)
    packadd repo
  endif
endfunction

" Bootstrap essential plugins required for installing and loading the rest.
call Ensure("wbthomason", "packer.nvim")

" map leader key to space
let g:mapleader = " "
let g:maplocalleader = " "

" disable builtin plugins I don't use
let g:loaded_gzip         = 1
let g:loaded_tar          = 1
let g:loaded_tarPlugin    = 1
let g:loaded_zipPlugin    = 1
let g:loaded_2html_plugin = 1
let g:loaded_netrw        = 1
let g:loaded_netrwPlugin  = 1
let g:loaded_matchit      = 1
let g:loaded_matchparen   = 1
let g:loaded_spec         = 1

" prevent typo when pressing `wq` or `q`
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))

" order matters
runtime! lua/modules/keymap.lua
runtime! lua/modules/options.lua
runtime! lua/modules/util.lua
runtime! lua/modules/mappings.vim
runtime! lua/modules/statusline.lua
