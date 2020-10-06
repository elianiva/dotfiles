" Set formatoptions
au FileType * setlocal formatoptions-=cro

" Enable completion and diagnostics
" au BufEnter * lua require'diagnostic'.on_attach()
" au BufEnter * lua require'completion'.on_attach()

" Set filetypes
au BufNewFile,BufRead *.ejs set filetype=html
au BufNewFile,BufRead *.json,.prettierrc,.eslintrc set filetype=jsonc

" Set tabsize for each filetype
au FileType go setlocal sw=8 ts=8
au FileType lua setlocal sw=2 ts=2
au FileType java setlocal sw=4 ts=4
au FileType php setlocal sw=4 ts=4

" Disable coc-emmet on these filetypes
au FileType javascript,typescript,typescriptreact call CocAction('toggleExtension', 'coc-emmet')

" Enable emmet.vim on these filetypes
au FileType html,javascript,php,xml,svelte,typescriptreact EmmetInstall

" Autoformat using prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
au BufWritePre *.js,*.jsx,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue,*.yaml,*.html,*.mjs Prettier

" Auto format go code
" au BufWritePre *.go :GoFmt

" Remove conceal in markdown
au FileType markdown setlocal conceallevel=0

" Set tsconfig.json to jsonc
au BufRead,BufNewFile tsconfig.json set ft=jsonc

" Remove trailing whitespace on save
au BufWritePre * %s/\s\+$//e

" Set PHP indentation
let b:PHP_default_indenting = 1
au BufReadPost * setlocal autoindent

" go to insert mode on nvim terminal
au BufEnter term://* startinsert

" Treat PHP file as php and html
" au FileType php set filetype=php.html

" set json comment highlighting
au FileType json syntax match Comment +\/\/.\+$+
