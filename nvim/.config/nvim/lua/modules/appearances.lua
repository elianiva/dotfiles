local hl = function(group, options)
  local bg = options.bg == nil and '' or 'guibg=' .. options.bg
  local fg = options.fg == nil and '' or 'guifg=' .. options.fg
  local gui = options.gui == nil and '' or 'gui=' .. options.gui

  vim.cmd(string.format(
    'hi %s %s %s %s',
    group, bg, fg, gui
  ))
end

apply_gruvbox = function()
  local highlights = {
    -- normal stuff
    {'Normal', { bg = 'NONE' }},
    {'SignColumn', { bg = 'NONE' }},
    {'GitGutterAdd', { fg = '#458588' }},
    {'GitGutterChange', { fg = '#D79921' }},
    {'GitGutterDelete', { fg = '#CC241D' }},
    {'jsonMissingCommaError', { fg = '#CC241D' }},
    {'jsonNoQuotesError', { fg = '#CC241D' }},

    -- statusline colours
    {'Active', { bg = '#3C3836', fg = '#EBDBB2' }},
    {'Inactive', { bg = '#504945', fg = '#1D2021' }},
    {'Mode', { bg = '#928374', fg = '#1D2021', gui="bold" }},
    {'LineCol', { bg = '#928374', fg = '#1D2021', gui="bold" }},
    {'Git', { bg = '#504945', fg = '#EBDBB2' }},
    {'Filetype', { bg = '#504945', fg = '#EBDBB2' }},
    {'Filename', { bg = '#504945', fg = '#EBDBB2' }},

    {'ModeAlt', { bg = '#504945', fg = '#928374' }},
    {'GitAlt', { bg = '#3C3836', fg = '#504945' }},
    {'LineColAlt', { bg = '#504945', fg = '#928374' }},
    {'FiletypeAlt', { bg = '#3C3836', fg = '#504945' }},

    -- luatree
    {'LuaTreeFolderIcon', { fg = '#D79921' }},
    {'LuaTreeIndentMarker', { fg = '#928374' }},
  }

  for _, highlight in pairs(highlights) do
    hl(highlight[1], highlight[2])
  end
end

-- TODO: convert this later
--[[
function CodeDark()
  hi Normal guibg=NONE
  hi SignColumn guibg=NONE
  hi GitGutterAdd guifg=#569cd6
  hi GitGutterChange guifg=#d7ba7d
  hi GitGutterDelete guifg=#d16969
  hi jsonMissingCommaError guifg=#d16969
  hi jsonNoQuotesError guifg=#d16969
  hi EndOfBuffer guibg=NONE
  hi NonText guibg=NONE
  hi LineNr guibg=NONE

  " Statusline colors
  hi Active guibg=#1e1e1e guifg=#d4d4d4
  hi Inactive guibg=#141414 guifg=#3c3c3c
  hi Git guibg=#2b2b2b guifg=#d4d4d4
  hi LineCol guibg=#3e3e3e guifg=#d4d4d4 gui=bold
  hi Mode guibg=#3d3d3d guifg=#d4d4d4 gui=bold
  hi Filetype guibg=#2b2b2b guifg=#d4d4d4
  hi Modi guibg=#2b2b2b guifg=#d4d4d4
  hi Filename guibg=#2b2b2b guifg=#d4d4d4

  " Lua tree
  hi LuaTreeFolderIcon guifg=#d16969
  hi LuaTreeIndentMarker guifg=#4a4a4a

  " Completion Menu
  hi Pmenu guibg=#1e1e1e
  hi PmenuSel guibg=#d16969 guifg=#2b2b2b
  hi PmenuSbar guibg=#2b2b2b guifg=#2b2b2b
  hi PmenuThumb guibg=#3e3e3e guifg=#3e3e3e

  " Telescope nvim
  hi TelescopeSelection gui=bold guifg=#d4d4d4 guibg=NONE
  hi TelescopeMatching gui=bold guifg=#d16969 guibg=NONE
  hi TelescopePreviewBorder gui=bold guifg=#3e3e3e guibg=NONE
  hi TelescopePromptBorder gui=bold guifg=#3e3e3e guibg=NONE
  hi TelescopeResultsBorder gui=bold guifg=#3e3e3e guibg=NONE
endfunction
--]]

-- italicize comments
hl('Comment', { gui = 'italic' })

-- automatically override colourscheme
vim.cmd('augroup NewColor')
vim.cmd('au!')
vim.cmd('au ColorScheme gruvbox call v:lua.apply_gruvbox()')
vim.cmd('augroup END')

-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false

vim.cmd('color gruvbox')
