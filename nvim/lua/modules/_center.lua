-- somewhat messy goyo clone
-- goyo has some issue with my colourscheme

local o, wo, a, g = vim.o, vim.wo, vim.api, vim.g
local M = {}

local is_centered = false
local win

M.centered = function()
  if is_centered then
    is_centered = false
    a.nvim_win_close(win)
  end

  is_centered = true

  local width, height = 80, 30
  local winwidth = o.columns
  local winheight = a.nvim_win_get_height(0)
  local bufnr = a.nvim_get_current_buf()
  o.laststatus = 0
  o.showtabline = 0
  o.ruler = false

  vim.cmd [[ tabnew ]]
  win = a.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (winwidth / 2) - (width / 2),
    row = (winheight / 2) - (height / 2),
    style = "minimal",
    border = {
      {" ", "Normal"}, {" ", "Normal"}, {" ", "Normal"}, {" ", "Normal"},
      {" ", "Normal"}, {" ", "Normal"}, {" ", "Normal"}, {" ", "Normal"},
    },
    zindex = 10
  })
  wo.winhl = 'Normal:Normal'
  wo.wrap = true
  wo.linebreak = true
end

return M
