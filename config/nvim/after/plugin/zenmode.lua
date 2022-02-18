require("zen-mode").setup {
  window = {
    backdrop = 1,
    width = 80,
    height = 32,
    linebreak = true,
    wrap = true,
  },
  plugins = {
    options = {
      enabled = true,
      ruler = false,
      showcmd = false,
    },
    gitsigns = { enabled = true }, -- disables git signs
    tmux = { enabled = false }, -- disables the tmux statusline
  },
  on_open = function(win)
    vim.api.nvim_win_set_option(win, "wrap", true)
    vim.api.nvim_win_set_option(win, "linebreak", true)
  end,
}
