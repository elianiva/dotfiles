local M = {}

M.plugin = {
  "NTBBloodbath/rest.nvim",
  keys = "<Plug>RestNvim",
  setup = function()
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>rr",
      "<Plug>RestNvim",
      { noremap = false }
    )
  end,
}

return M
