local fn = vim.fn
local api = vim.api

local M = {}

M.trunc_width = setmetatable({
  git_status = 90,
  filename = 140,
}, {
  __index = function()
    return 80
  end,
})

M.is_truncated = function(_, width)
  local current_width = api.nvim_win_get_width(0)
  return current_width < width
end

M.modes = setmetatable({
  ["n"] = "N",
  ["no"] = "N·P",
  ["v"] = "V",
  ["V"] = "V·L",
  [""] = "V·B", -- this is not ^V, but it's , they're different
  ["s"] = "S",
  ["S"] = "S·L",
  [""] = "S·B", -- same with this one, it's not ^S but it's 
  ["i"] = "I",
  ["ic"] = "I",
  ["R"] = "R",
  ["Rv"] = "V·R",
  ["c"] = "C",
  ["cv"] = "V·E",
  ["ce"] = "E",
  ["r"] = "P",
  ["rm"] = "M",
  ["r?"] = "C",
  ["!"] = "S",
  ["t"] = "T",
}, {
  __index = function()
    return "U" -- handle edge cases
  end,
})

M.get_current_mode = function(self)
  local current_mode = api.nvim_get_mode().mode
  return string.format(" [%s] ", self.modes[current_mode]):upper()
end

M.get_git_status = function(self)
  -- use fallback because it doesn't set this variable on the initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict
    or { head = "", added = 0, changed = 0, removed = 0 }
  local is_head_empty = signs.head ~= ""

  if self:is_truncated(self.trunc_width.git_status) then
    return is_head_empty and string.format(" [ %s] ", signs.head or "") or ""
  end

  return is_head_empty
      and string.format(
        " [+%s ~%s -%s] [ %s] ",
        signs.added,
        signs.changed,
        signs.removed,
        signs.head
      )
    or ""
end

M.get_filepath = function(self)
  local filepath = fn.fnamemodify(fn.expand "%", ":.:h")
  if
    filepath == ""
    or filepath == "."
    or self:is_truncated(self.trunc_width.filename)
  then
    return " "
  end

  return string.format(" %%<%s/", filepath)
end

M.get_filename = function()
  local filename = fn.expand "%:t"
  if filename == "" then
    return ""
  end
  return filename
end

M.get_filetype = function()
  local filetype = vim.bo.filetype
  if filetype == "" then
    return " No FT "
  end

  return string.format("[ft: %s] ", filetype):lower()
end

M.get_fileformat = function()
  return string.format("[%s]", vim.o.fileformat):lower()
end

M.get_line_col = function()
  return "[%l:%c]"
end

M.lsp_progress = function()
  local lsp = vim.lsp.util.get_progress_messages()[1]
  if lsp then
    local name = lsp.name or ""
    local msg = lsp.message or ""
    local percentage = lsp.percentage or 0
    local title = lsp.title or ""
    return string.format(
      " %%<%s: %s %s (%s%%%%) ",
      name,
      title,
      msg,
      percentage
    )
  end

  return ""
end

M.set_active = function(self)
  return table.concat {
    "%#StatusLine#",
    self:get_current_mode(),
    "%#StatusLineAccent#",
    self:get_line_col(),
    "%#StatusLine#",
    self:get_filepath(),
    self:get_filename(),
    "%=",
    self:lsp_progress(),
    self:get_filetype(),
    self:get_fileformat(),
    self:get_git_status(),
  }
end

M.set_inactive = function()
  return "%#StatusLineNC#" .. "%= %F %="
end

M.set_explorer = function()
  return "%#StatusLineNC#"
end

Statusline = setmetatable(M, {
  __call = function(self, mode)
    return self["set_" .. mode](self)
  end,
})

-- set statusline
-- TODO(elianiva): replace this once we can define autocmd using lua
vim.cmd [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('explorer')
  augroup END
]]
