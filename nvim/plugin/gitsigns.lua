require("gitsigns").setup {
  signs = {
    add          = { hl = "SignAdd",    text = "┃" },
    change       = { hl = "SignChange", text = "┃" },
    delete       = { hl = "SignDelete", text = "┃" },
    topdelete    = { hl = "SignDelete", text = "┃" },
    changedelete = { hl = "SignChange", text = "┃" },
  },
  keymaps = {
    noremap = true,
    buffer = true,
    ["n <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ["n <leader>hu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ["n <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ["n <leader>hR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ["n <leader>hp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line()<CR>',
  },
  watch_index = {
    interval = 1000,
  },
  preview_config = {
    border = Util.borders,
  },
  current_line_blame = false,
  sign_priority = 5,
  update_debounce = 500,
  status_formatter = nil, -- Use default
  use_decoration_api = true,
  use_internal_diff = true,
}
