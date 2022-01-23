" enable filetype.lua
let g:do_filetype_lua = 1

" disable filetype.vim
let g:did_load_filetypes = 0

" Set current working directory
au VimEnter * cd %:p:h

" Remove trailing whitespace on save
let g:strip_whitespace = v:true
augroup Whitespace
  au!
  au BufWritePre * if g:strip_whitespace | %s/\s\+$//e
augroup END

" automatically go to insert mode on terminal buffer
autocmd BufEnter term://* startinsert

" highlight yanked text for 250ms
augroup Yank
  au!
  au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250, higroup = "Visual" }
augroup END
