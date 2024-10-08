return {
  "rcarriga/nvim-notify",
  opts = {
    on_open = function(win)
      local config = vim.api.nvim_win_get_config(win)
      config.border = "single"
      vim.api.nvim_win_set_config(win, config)
    end,
    top_down = false
  },
}
