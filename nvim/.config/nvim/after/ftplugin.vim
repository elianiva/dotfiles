" Set formatoptions
au FileType * setlocal formatoptions-=cro

" Set filetypes
au BufNewFile,BufRead *.ejs,*.hbs set filetype=html
au BufNewFile,BufRead *.json,.prettierrc,.eslintrc set filetype=jsonc
au BufRead,BufNewFile *.json set ft=jsonc
au BufRead,BufNewFile *.svx,*.mdx set ft=markdown

" Set tabsize for each filetype
au FileType go setlocal sw=8 ts=8
au FileType lua setlocal sw=2 ts=2
au FileType java setlocal sw=4 ts=4
au FileType php setlocal sw=4 ts=4

" Enable emmet.vim on these filetypes
au FileType html,javascript,php,xml,svelte,typescriptreact EmmetInstall

" Remove conceal in markdown
au FileType markdown setlocal conceallevel=0

" Remove trailing whitespace on save
au BufWritePre * %s/\s\+$//e

" Set PHP indentation
let b:PHP_default_indenting = 1

" go to insert mode on nvim terminal
au BufEnter term://* startinsert

" Treat PHP file as php and html
" au FileType php set filetype=php.html

" set json comment highlighting
au FileType json syntax match Comment +\/\/.\+$+

" enable/disable wordwrap
augroup Goyo
  au!
  au User GoyoEnter setlocal linebreak wrap
  au User GoyoLeave setlocal nolinebreak nowrap
augroup END
