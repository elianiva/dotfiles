" Set filetypes
augroup Filetypes
  au!
  au BufNewFile,BufRead *.ejs set filetype=html
  au BufNewFile,BufRead .prettierrc,.eslintrc,tsconfig.json set filetype=jsonc
  au BufNewFile,BufRead *.svx,*.mdx set ft=markdown
  au BufNewFile,BufRead *.svelte set ft=svelte
  au BufNewFile,BufRead *.zig set ft=zig
  au BufNewFile,BufRead *.hbs set ft=handlebars
  au BufNewFile,BufRead *.edge set ft=html
augroup END

" Set github text field to markdown (firenvim stuff)
au BufEnter github.com_*.txt set filetype=markdown

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

" augroup Emmet
"   au!
"   au FileType html,javascript,typescript,javascriptreact,typescriptreact,svelte EmmetInstall
" augroup END
