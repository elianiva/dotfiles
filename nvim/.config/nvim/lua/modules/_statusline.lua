local Job = require("plenary.job")
local fn = vim.fn

-- change them if you want to different separator
local left_sep = ''
local right_sep = ''
local thin_sep = ''
-- local left_sep = ''
-- local right_sep = ''
-- local thin_sep = ''

-- highlight groups
local colors = {
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

local is_truncated = function(width)
  local current_window = fn.winnr()
  local current_width = fn.winwidth(current_window)
  return current_width < width
end

--[[
  NOTE: I don't use this since the statusline already has
  so much stuff going on. Feel free to use it!
  credit: https://github.com/nvim-lua/lsp-status.nvim
--]]
-- local get_lsp_diagnostic = function()
--   local result = {}
--   local levels = {
--     errors = 'Error',
--     warnings = 'Warning',
--     info = 'Information',
--     hints = 'Hint'
--   }

  -- for k, level in pairs(levels) do
  --   result[k] = vim.lsp.util.buf_diagnostics_count(level)
  -- end

  -- if is_truncated() then
  --   return ''
  -- else
  --   return string.format(
  --     "| E:%s W:%s I:%s H:%s ",
  --     result['errors'] or 0, result['warnings'] or 0,
  --     result['info'] or 0, result['hints'] or 0
  --   )
  -- end
-- end

local get_current_mode = function()
  local modes = {
    ['n']  = { 'Normal', 'N' };
    ['no'] = { 'N·Pending', 'N' };
    ['v']  = {'Visual', 'V' };
    ['V']  = {'V·Line', 'V' };
    [''] = {'V·Block', 'V'};
    ['s']  = {'Select', 'S'};
    ['S']  = {'S·Line', 'S'};
    ['^S'] = {'S·Block', 'S'};
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

  if is_truncated(80) then
    return string.format(' %s ', modes[current_mode][2]):upper()
  else
    return string.format(' %s ', modes[current_mode][1]):upper()
  end
end

-- taken from expressline and modified a bit
-- https://github.com/tjdevries/express_line.nvim/
local get_git_status = function()
  local s = vim.call('sy#repo#get_stats')
  local job = Job:new({
    command = "git",
    args = {"branch", "--show-current"},
    cwd = fn.fnamemodify(fn.bufname(0), ":h"),
  })

  local ok, branch = pcall(function()
    return vim.trim(job:sync()[1])
  end)

  if ok then
    if is_truncated(90) or s[1] == -1 then
      return string.format('  %s ', branch)
    else
      return string.format(
        ' +%s ~%s -%s |  %s ',
        s[1], s[2], s[3], branch
      )
    end
  else
    return ''
  end
end

local get_filename = function()
  local filename = fn.expand('%:t')
  return string.format(' %s ', filename)
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
  if is_truncated(60) then
    return ' %l:%c '
  else
    return ' Ln %l, Col %c '
  end
end

Statusline = {}

Statusline.active = function()
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
  -- local diagnostic = colors.line_col .. get_lsp_diagnostic()

  return table.concat({
    colors.active,
    mode, mode_alt, git, git_alt,
    mid,
    filename_alt, filename, thin_sep, filetype, line_col_alt, line_col,
    -- diagnostic
  })
end

Statusline.inactive = function()
  return colors.inactive .. ' %F '
end

Statusline.explorer = function()
  local title = colors.mode .. ' EXPLORER '
  local title_alt = colors.mode_alt .. left_sep

  return table.concat({
    colors.active, title, title_alt
  })
end

-- set statusline
vim.cmd('augroup Statusline')
vim.cmd('au!')
vim.cmd('au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()')
vim.cmd('au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()')
vim.cmd('au WinEnter,BufEnter,FileType LuaTree setlocal statusline=%!v:lua.Statusline.explorer()')
vim.cmd('augroup END')
