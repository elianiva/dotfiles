local vim = vim

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
    {'Comment', { gui = 'italic' }},
    {'SignColumn', { bg = 'NONE' }},
    {'ColorColumn', { bg = '#3C3836' }},
    -- {'GitGutterAdd', { fg = '#458588' }},
    -- {'GitGutterChange', { fg = '#D79921' }},
    -- {'GitGutterDelete', { fg = '#CC241D' }},
    {'SignifySignAdd', { fg = '#458588', bg = 'NONE' }},
    {'SignifySignChange', { fg = '#D79921', bg = 'NONE' }},
    {'SignifySignDelete', { fg = '#CC241D', bg = 'NONE' }},
    {'GitGutterChange', { fg = '#D79921' }},
    {'GitGutterDelete', { fg = '#CC241D' }},
    {'jsonMissingCommaError', { fg = '#CC241D' }},
    {'jsonNoQuotesError', { fg = '#CC241D' }},
    {'IncSearch', { bg='#282828', fg='#928374' }},

    -- statusline colours
    {'Active', { bg = 'blue', fg = '#EBDBB2' }},
    {'Inactive', { bg = '#3C3836', fg = '#928374' }},
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

    -- telescope
    {'TelescopeSelection', { bg='NONE', fg='#D79921', gui='bold' }},
    {'TelescopeMatching', { bg='NONE', fg='#CC241D', gui='bold' }},
    {'TelescopeBorder', { bg='NONE', fg='#928374', gui='bold' }},
  }

  for _, highlight in pairs(highlights) do
    hl(highlight[1], highlight[2])
  end
end

apply_eunoia = function()
  local highlights = {
    -- statusline colours
    {'Active', { bg = '#211D35', fg = '#ECEBE6' }},
    {'Inactive', { bg = '#2C2941', fg = '#4B5573' }},
    {'Mode', { bg = '#6391F4', fg = '#211D35', gui="bold" }},
    {'LineCol', { bg = '#E64557', fg = '#211D35', gui="bold" }},
    {'Git', { bg = '#2C2941', fg = '#ECEBE6' }},
    {'Filetype', { bg = '#2C2941', fg = '#ECEBE6' }},
    {'Filename', { bg = '#2C2941', fg = '#ECEBE6' }},

    {'ModeAlt', { bg = '#2C2941', fg = '#6391F4' }},
    {'GitAlt', { bg = '#211D35', fg = '#2C2941' }},
    {'LineColAlt', { bg = '#2C2941', fg = '#E64557' }},
    {'FiletypeAlt', { bg = '#211D35', fg = '#2C2941' }},

    -- telescope
    {'TelescopeSelection', { bg='#211D35', fg='#6370F4' }},
    {'TelescopeMatching', { bg='#211D35', fg='#58CDFF' }},
    {'TelescopeBorder', { bg='#211D35', fg='#4B5573' }},
    {'TelescopeNormal', { bg='#211D35' }},
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
vim.cmd('au ColorScheme gruvbox call v:lua.treesitter_hl()')
vim.cmd('au ColorScheme eunoia call v:lua.apply_eunoia()')
vim.cmd('augroup END')

-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false
vim.cmd('color gruvbox')

-- needs to be loaded after setting colourscheme
require'nvim-web-devicons'.setup {
  override = {
    svg = {
      icon = "",
      color = "#ebdbb2",
      name = "Svg"
    }
  };
  default = true
}
