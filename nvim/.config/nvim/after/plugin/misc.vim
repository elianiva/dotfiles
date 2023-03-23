nnoremap <silent> <A-j> <CMD>Sayonara!<CR>
nnoremap <silent> <A-k> <CMD>Sayonara<CR>

xmap ga <Plug>(EasyAlign)

" https://gitlab.com/yorickpeterse/nvim-pqf
lua require("pqf").setup()

let g:matchup_matchparen_offscreen = {
      \ "method": "popup",
      \ "fullwidth": v:true,
      \ "highlight": "Normal"
      \ }
