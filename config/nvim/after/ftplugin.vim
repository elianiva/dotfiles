" Set filetypes
augroup Filetypes
  au!
  au BufNewFile,BufRead *.ejs,*.hbs set filetype=html
  au BufNewFile,BufRead .prettierrc,.eslintrc,tsconfig.json set filetype=jsonc
  au BufNewFile,BufRead *.svx,*.mdx set ft=markdown
  au BufNewFile,BufRead *.svelte set ft=svelte
  au BufNewFile,BufRead *.nix set ft=nix
  au BufNewFile,BufRead *.zig set ft=zig
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

" disable nvim-compe inside telescope
augroup Compe
  au!
  au WinLeave,FileType TelescopePrompt let g:compe_enabled = v:true
  au WinEnter,FileType TelescopePrompt let g:compe_enabled = v:false
augroup END

" highlight yanked text for 250ms
augroup Yank
  au!
  au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250, higroup = "Visual" }
augroup END

augroup Emmet
  au!
  au FileType html,javascript,typescript,javascriptreact,typescriptreact,svelte EmmetInstall
augroup END
