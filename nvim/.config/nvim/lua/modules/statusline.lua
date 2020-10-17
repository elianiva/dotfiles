-- change them if you want to different separator
local left_sep = ''
local right_sep = ''
local thin_sep = ''

-- highlight groups
local colors = {
  active        = '%#Active#',
  inactive      = '%#Inactive#',
  mode          = '%#Mode#',
  mode_alt      = '%#ModeAlt#',
  git           = '%#Git#',
  git_alt       = '%#GitAlt#',
  filetype      = '%#Filetype#',
  filetype_alt  = '%#FiletypeAlt#',
  line_col      = '%#LineCol#',
  line_col_alt  = '%#LineColAlt#',
}

local is_truncated = function()
  local current_window = vim.fn.winnr()
  local current_width = vim.fn.winwidth(current_window)
  return current_width > 80
end

local get_current_mode = function()
  local modes = {
    n      = { 'Normal', 'N' };
    no     = { 'N·Pending', 'N' };
    v      = { 'Visual', 'V' };
    V      = { 'V·Line', 'V' };
    ['^V'] = {'V·Block', 'V'};
    s      = {'Select', 'S'};
    S      = {'S·Line', 'S'};
    ['^S'] = {'S·Block', 'S'};
    i      = {'Insert', 'S'};
    R      = {'Replace', 'R'};
    Rv     = {'V·Replace', 'V'};
    c      = {'Command', 'C'};
    cv     = {'Vim Ex ', 'V'};
    ce     = {'Ex ', 'E'};
    r      = {'Prompt ', 'P'};
    rm     = {'More ', 'M'};
    ['r?'] = {'Confirm ', 'C'};
    ['!']  = {'Shell ', 'S'};
    t      = {'Terminal ', 'T'};
  }

  local current_mode = vim.fn.mode()

  if is_truncated() then
    return string.format(' %s ', modes[current_mode][1]):upper()
  else
    return string.format(' %s ', modes[current_mode][2]):upper()
  end
end

local get_git_status = function()
  local s = vim.call('sy#repo#get_stats')
  local branch = vim.call('fugitive#head')

  if branch == '' then
    return ''
  else
    return string.format(
      ' +%s ~%s -%s |  %s ',
      s[1], s[2], s[3], branch
    )
  end
end

local get_filename = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t')
  local icon = require'nvim-web-devicons'.get_icon(
    filename, filetype, { default = true }
  )

  return string.format(' %s %s ', icon, filename)
end

local get_filetype = function()
  local filetype = vim.bo.filetype
  if filetype == '' then
    return ''
  else
    return string.format(' %s ', filetype):lower()
  end
end

local get_line_col = function()
  if is_truncated() then
    return ' Ln %l, Col %c '
  else
    return ' %l:%c '
  end
end

statusline = {}

statusline.active = function()
  local mid = "%="
  local mode = colors.mode .. get_current_mode()
  local mode_alt = colors.mode_alt .. left_sep
  local git = colors.git .. get_git_status()
  local git_alt = colors.git_alt .. left_sep
  local filename = colors.filetype .. get_filename()
  local filename_alt = colors.filetype_alt .. right_sep
  local filetype = colors.filetype .. get_filetype()
  local line_col = colors.line_col .. get_line_col()
  local line_col_alt = colors.line_col_alt .. right_sep

  return table.concat({
    colors.active,
    mode, mode_alt, git, git_alt,
    mid,
    filename_alt, filename, thin_sep, filetype, line_col_alt, line_col
  })
end

statusline.inactive = function()
  return colors.inactive .. '%F '
end

statusline.explorer = function()
  local title = colors.mode .. ' Explorer '
  local title_alt = colors.mode_alt .. left_sep

  return table.concat({
    colors.active, title:upper(), title_alt
  })
end

-- set statusline
vim.cmd('augroup Statusline')
vim.cmd('au!')
vim.cmd('au WinEnter,BufEnter * setlocal statusline=%!v:lua.statusline.active()')
vim.cmd('au WinLeave,BufLeave * setlocal statusline=%!v:lua.statusline.inactive()')
vim.cmd('au WinEnter,BufEnter,FileType LuaTree setlocal statusline=%!v:lua.statusline.explorer()')
vim.cmd('augroup END')

