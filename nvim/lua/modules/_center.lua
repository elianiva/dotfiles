-- somewhat messy goyo clone
-- goyo has some issue with my colourscheme

local o, wo, a, g = vim.o, vim.wo, vim.api, vim.g
local M = {}

local user = {
  stl = o.laststatus,
  tab = o.showtabline,
  fill = o.fillchars,
}

local toggle_decoration = function(hidden)
  o.laststatus = hidden and 0 or user.stl
  o.showtabline = hidden and 0 or user.tab
  o.fillchars = hidden and "vert: ,eob: " or user.fill
  wo.fillchars = hidden and "vert: ,eob: " or user.fill
  wo.linebreak = hidden
  wo.wrap = hidden
end

local split = function(curr_win, direction, width)
  o.splitright = direction == "right"

  vim.cmd (width .. "vnew | setlocal buftype=nofile | setlocal bufhidden=wipe")
  wo.cursorline = false

  local buf = a.nvim_get_current_buf()
  a.nvim_buf_set_name(buf, direction)
  a.nvim_set_current_win(curr_win)
end

M.centered = function()
  local win = a.nvim_get_current_win()
  local width = math.floor((o.columns - 80) / 2)

  if g.centered then
    vim.cmd [[
      bwipeout left right | set nolinebreak | set nowrap
    ]]
    toggle_decoration(false)
    wo.cursorline = true
    g.centered = false
    wo.signcolumn = "yes"
    return
  end

  split(win, "left", width)
  split(win, "right", width)
  toggle_decoration(true)
  wo.cursorline = false
  wo.signcolumn = "no"
  g.centered = true
end

return M
