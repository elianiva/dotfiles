require'gitsigns'.setup {
  signs = {
    add          = {hl = 'SignifySignAdd'   , text = '┃'},
    change       = {hl = 'SignifySignChange', text = '┃'},
    delete       = {hl = 'SignifySignDelete', text = '┃'},
    topdelete    = {hl = 'SignifySignDelete', text = '┃'},
    changedelete = {hl = 'SignifySignChange', text = '┃'},
  },
  sign_priority = 5,
}
