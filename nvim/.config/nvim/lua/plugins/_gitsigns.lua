vim.cmd[[packadd gitsigns.nvim]]

require'gitsigns'.setup {
  signs = {
    add          = {hl = 'SignAdd'   , text = '┃'},
    change       = {hl = 'SignChange', text = '┃'},
    delete       = {hl = 'SignDelete', text = '┃'},
    topdelete    = {hl = 'SignDelete', text = '┃'},
    changedelete = {hl = 'SignChange', text = '┃'},
  },
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,

    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

    -- ['n <leader>hs'] = nil,
    -- ['n <leader>hu'] = nil,
    -- ['n <leader>hr'] = nil,
    -- ['n <leader>hp'] = nil,
    -- ['n <leader>hb'] = nil,

    -- Text objects
    ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
    ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>'
  },
  sign_priority = 5,
}
