local fn = vim.fn

Statusline = {}

-- change them if you want to different separator
Statusline.separators = {
  arrow = { '', '' },
  rounded = { '', '' },
}

-- highlight groups
Statusline.colors = {
  active        = '%#StatusLine#',
  inactive      = '%#StatuslineNC#',
  mode          = '%#Mode#',
  mode_alt      = '%#ModeAlt#',
  git           = '%#Git#',
  git_alt       = '%#GitAlt#',
  filetype      = '%#Filetype#',
  filetype_alt  = '%#FiletypeAlt#',
  line_col      = '%#LineCol#',
  line_col_alt  = '%#LineColAlt#',
}

Statusline.is_truncated = function(_, width)
  local current_window = fn.winnr()
  local current_width = fn.winwidth(current_window)
  return current_width < width
end

----[[
--  NOTE: I don't use this since the statusline already has
--  so much stuff going on. Feel free to use it!
--  credit: https://github.com/nvim-lua/lsp-status.nvim
----]]
-- Statusline.get_lsp_diagnostic = function(self)
--   local result = {}
--   local levels = {
--     errors = 'Error',
--     warnings = 'Warning',
--     info = 'Information',
--     hints = 'Hint'
--   }

--   for k, level in pairs(levels) do
--     result[k] = vim.lsp.diagnostic.get_count(0, level)
--   end

--   if self:is_truncated(120) then
--     return ''
--   else
--     return string.format(
--       "| :%s :%s :%s :%s ",
--       result['errors'] or 0, result['warnings'] or 0,
--       result['info'] or 0, result['hints'] or 0
--     )
--   end
-- end

Statusline.get_current_mode = function(self)
  local modes = {
    ['n']  = {'Normal', 'N'};
    ['no'] = {'N·Pending', 'N'} ;
    ['v']  = {'Visual', 'V' };
    ['V']  = {'V·Line', 'V' };
    [''] = {'V·Block', 'V'}; -- this is not ^V, but it's , they're different
    ['s']  = {'Select', 'S'};
    ['S']  = {'S·Line', 'S'};
    [''] = {'S·Block', 'S'};
    ['i']  = {'Insert', 'S'};
    ['R']  = {'Replace', 'R'};
    ['Rv'] = {'V·Replace', 'V'};
    ['c']  = {'Command', 'C'};
    ['cv'] = {'Vim Ex ', 'V'};
    ['ce'] = {'Ex ', 'E'};
    ['r']  = {'Prompt ', 'P'};
    ['rm'] = {'More ', 'M'};
    ['r?'] = {'Confirm ', 'C'};
    ['!']  = {'Shell ', 'S'};
    ['t']  = {'Terminal ', 'T'};
  }

  local current_mode = fn.mode()

  if self:is_truncated(80) then
    return string.format(' %s ', modes[current_mode][2]):upper()
  else
    return string.format(' %s ', modes[current_mode][1]):upper()
  end
end

Statusline.get_git_status = function(self)
  -- use fallback because it doesn't set this variable on initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict or {head = '', added = 0, changed = 0, removed = 0}

  if self:is_truncated(90) then
    if signs.head ~= '' then
      return string.format('  %s ', signs.head or '')
    else
      return ''
    end
  else
    if signs.head ~= '' then
      return string.format(
        ' +%s ~%s -%s |  %s ',
        signs.added, signs.changed, signs.removed, signs.head
      )
    else
      return ''
    end
  end
end

Statusline.get_filename = function(self)
  if self:is_truncated(140) then
    return " %<%f "
  else
    return " %<%F "
  end
end

Statusline.get_filetype = function()
  local filetype = vim.bo.filetype
  if filetype == '' then
    return ''
  else
    return string.format(' %s ', filetype):lower()
  end
end

Statusline.get_line_col = function(self)
  if self:is_truncated(60) then
    return ' %l:%c '
  else
    return ' Ln %l, Col %c '
  end
end


Statusline.set_active = function(self)
  local mode = self.colors.mode .. self:get_current_mode()
  local mode_alt = self.colors.mode_alt .. self.separators.arrow[1]
  local git = self.colors.git .. self:get_git_status()
  local git_alt = self.colors.git_alt .. self.separators.arrow[1]
  local filename = self.colors.inactive .. self:get_filename()
  local filetype_alt = self.colors.filetype_alt .. self.separators.arrow[2]
  local filetype = self.colors.filetype .. self:get_filetype()
  local line_col = self.colors.line_col .. self:get_line_col()
  local line_col_alt = self.colors.line_col_alt .. self.separators.arrow[2]

  return table.concat({
    self.colors.active,
    mode, mode_alt, git, git_alt,
    "%=", filename, "%=",
    filetype_alt, filetype, line_col_alt, line_col
  })
end

Statusline.set_inactive = function(self)
  return self.colors.inactive .. '%= %F %='
end

Statusline.set_explorer = function(self)
  local title = self.colors.mode .. '  '
  local title_alt = self.colors.mode_alt .. self.separators.arrow[1]

  return table.concat({
    self.colors.active, title, title_alt
  })
end

Statusline.active = function() return Statusline:set_active() end
Statusline.inactive = function() return Statusline:set_inactive() end
Statusline.explorer = function() return Statusline:set_explorer() end

-- set statusline
vim.cmd('augroup Statusline')
vim.cmd('au!')
vim.cmd('au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()')
vim.cmd('au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()')
vim.cmd('au WinEnter,BufEnter,FileType LuaTree setlocal statusline=%!v:lua.Statusline.explorer()')
vim.cmd('augroup END')
