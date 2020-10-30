" Set formatoptions
au FileType * setlocal formatoptions-=cro

" Set filetypes
au BufNewFile,BufRead *.ejs set filetype=html
au BufNewFile,BufRead *.json,.prettierrc,.eslintrc set filetype=jsonc

" Set tabsize for each filetype
au FileType go setlocal sw=8 ts=8
au FileType lua setlocal sw=2 ts=2
au FileType java setlocal sw=4 ts=4
au FileType php setlocal sw=4 ts=4

" Enable emmet.vim on these filetypes
au FileType html,javascript,php,xml,svelte,typescriptreact EmmetInstall

" Auto format go code
" au BufWritePre *.go :GoFmt

" Remove conceal in markdown
au FileType markdown setlocal conceallevel=0

" Set tsconfig.json to jsonc
au BufRead,BufNewFile tsconfig.json set ft=jsonc

" Set mdsvex to markdown filetype
au BufRead,BufNewFile *.svx set ft=markdown

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
