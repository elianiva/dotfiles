return {
  "rcarriga/nvim-notify",
  opts = {
    render = "compact",
    on_open = function(win)
      local config = vim.api.nvim_win_get_config(win)
      config.border = "solid"
      vim.api.nvim_win_set_config(win, config)
    end,
    top_down = false
  },
}
