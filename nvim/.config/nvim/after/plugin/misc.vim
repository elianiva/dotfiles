nnoremap <silent> <A-j> <CMD>Sayonara!<CR>
nnoremap <silent> <A-k> <CMD>Sayonara<CR>

xmap ga <Plug>(EasyAlign)

" https://gitlab.com/yorickpeterse/nvim-pqf
lua require("pqf").setup()

imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
packadd copilot.vim

let g:matchup_matchparen_offscreen = {
      \ "method": "popup",
      \ "fullwidth": v:true,
      \ "highlight": "Normal"
      \ }
