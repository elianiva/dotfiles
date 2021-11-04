require("gitsigns").setup {
  signs = {
    add          = { hl = "SignAdd",    text = "▎" },
    change       = { hl = "SignChange", text = "▎" },
    delete       = { hl = "SignDelete", text = "🭻" },
    topdelete    = { hl = "SignDelete", text = "🭶" },
    changedelete = { hl = "SignChange", text = "▎" },
  },
  keymaps = {
    noremap = true,
    buffer = true,
    ["n <leader>hp"] = '<cmd>lua require("gitsigns").next_hunk()<CR>',
    ["n <leader>hn"] = '<cmd>lua require("gitsigns").prev_hunk()<CR>',
    ["n <leader>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
    ["n <leader>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
    ["n <leader>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ["n <leader>hb"] = '<cmd>lua require("gitsigns").blame_line()<CR>',
    ["n <leader>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
    ["n <leader>hP"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
  },
  watch_gitdir = {
    interval = 1000,
  },
  preview_config = {
    border = Util.borders,
  },
  current_line_blame = false,
  sign_priority = 5,
  update_debounce = 500,
  status_formatter = nil, -- Use default
  diff_opts = {
    internal = true,
  }
}
