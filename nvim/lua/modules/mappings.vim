" https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
noremap n "Nn"[v:searchforward]
noremap N "nN"[v:searchforward]

" toggle nvimtree
nnoremap <C-n> <CMD>NvimTreeToggle<CR>

" in terminal
" move between window
tnoremap <C-h> <C-\><C-n><C-w><C-h>
tnoremap <C-j> <C-\><C-n><C-w><C-j>
tnoremap <C-k> <C-\><C-n><C-w><C-k>
" tnoremap <C-l> <C-\><C-n><C-w><C-l>

" resize
tnoremap <Left>  <C-\><C-n>:vertical resize +2<CR>
tnoremap <Right> <C-\><C-n>:vertical resize -2<CR>
tnoremap <Up>    <C-\><C-n>:resize   +2<CR>
tnoremap <Down>  <C-\><C-n>:resize   -2<CR>
" move buffer
tnoremap <A-h> <C-\><C-n>:bp<CR>
tnoremap <A-l> <C-\><C-n>:bn<CR>
" go to normal mode using double esc
tnoremap <Esc><Esc> <C-\\><C-n>

" better movement between windows
nnoremap <C-h> <C-w><C-h>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>

" resize buffer easier
nnoremap <Left>  <CMD>vertical resize +2<CR>
nnoremap <Right> <CMD>vertical resize -2<CR>
nnoremap <Up>    <CMD>resize   +2<CR>
nnoremap <Down>  <CMD>resize   -2<CR>

" buffer movements
noremap <A-h> <CMD>bp<CR>
noremap <A-l> <CMD>bn<CR>

" move vertically by visual line on wrapped lines
nnoremap j gj
nnoremap k gk

" better yank behaviour
nnoremap Y y$

" remove annoying exmode
nnoremap Q  <Nop>
nnoremap q: <Nop>

" copy to system clipboard
vnoremap <A-y> "+y

" rl stands for `run lua`
nnoremap <Leader>rl <CMD>luafile %<CR>

" rn stands for `run node`
nnoremap <Leader>rn <CMD>!node %<CR>

" rd stands for `run deno`
nnoremap <Leader>rd <CMD>!NO_COLOR=true deno run %<CR>

" toggle hlsearch
nnoremap <Leader>n <CMD>nohl<CR>

noremap <Leader>v
      \ :exe "vnew"<CR>
      \ :exe "setlocal buftype=nofile bufhidden=hide"<CR>

" better indenting experience
vnoremap < <gv
vnoremap > >gv

noremap <F2>
      \ :exe "let g:strip_whitespace = !g:strip_whitespace"<CR>
      \ :exe "echo 'Strip whitespace mode toggled!'"<CR>
