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

local current_mode = function()
  local modes = {
    n      = 'Normal',
    no     = 'N·Operator Pending',
    v      = 'Visual',
    V      = 'V·Line',
    ['^V'] = 'V·Block',
    s      = 'Select',
    S      = 'S·Line',
    ['^S'] = 'S·Block',
    i      = 'Insert',
    R      = 'Replace',
    Rv     = 'V·Replace',
    c      = 'Command',
    cv     = 'Vim Ex ',
    ce     = 'Ex ',
    r      = 'Prompt ',
    rm     = 'More ',
    ['r?'] = 'Confirm ',
    ['!']  = 'Shell ',
    t      = 'Terminal '
  }

  local current_mode = vim.fn.mode()
  return string.format(' %s ', modes[current_mode]):upper()
end

local git_status = function()
  local s = vim.call('GitGutterGetHunkSummary')
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

local filename = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t')
  local icon = require'nvim-web-devicons'.get_icon(
    filename, filetype, { default = true }
  )

  return string.format(' %s %s ', icon, filename)
end

local filetype = function()
  local filetype = vim.bo.filetype
  if filetype == '' then
    return ''
  else
    return string.format(' %s ', filetype):lower()
  end
end

statusline = {}

statusline.active = function()
  local mid = "%="
  local mode = colors.mode .. current_mode()
  local mode_alt = colors.mode_alt .. left_sep
  local git = colors.git .. git_status()
  local git_alt = colors.git_alt .. left_sep
  local filename = colors.filetype .. filename()
  local filename_alt = colors.filetype_alt .. right_sep
  local filetype = colors.filetype .. filetype()
  local line_col_alt = colors.line_col_alt .. right_sep
  local line_col = colors.line_col .. ' Ln %l, Col %c '

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
