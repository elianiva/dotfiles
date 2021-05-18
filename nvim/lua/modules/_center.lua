-- somewhat messy goyo clone
-- goyo has some issue with my colourscheme

local o, wo, a, g = vim.o, vim.wo, vim.api, vim.g
local M = {}

M.centered = function()
  local width, height = 80, 30
  local winwidth = vim.o.columns
  local winheight = a.nvim_win_get_height(0)
  local bufnr = a.nvim_get_current_buf()
  vim.o.laststatus = 0
  vim.o.showtabline = 0
  vim.o.ruler = false

  vim.cmd [[ tabnew ]]
  local win = a.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (winwidth / 2) - (width / 2),
    row = (winheight / 2) - (height / 2),
    style = "minimal",
    border = {
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
      {" ", "Normal"},
    },
    zindex = 10
  })
  vim.wo.winhl = 'Normal:Normal'
end

return M
