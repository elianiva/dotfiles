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

ColorUtil = {}

ColorUtil.override_gruvbox = function()
  local highlights = {
    -- normal stuff
    {'Normal', { bg = 'NONE' }},
    {'Comment', { gui = 'italic' }},
    {'Identifier', { fg = '#EBDBB2' }},
    {'TSProperty', { fg = '#83a589' }},
    {'SignColumn', { bg = 'NONE' }},
    {'ColorColumn', { bg = '#3C3836' }},

    {'SignifySignAdd', { fg = '#458588', bg = 'NONE' }},
    {'SignifySignChange', { fg = '#D79921', bg = 'NONE' }},
    {'SignifySignDelete', { fg = '#fb4934', bg = 'NONE' }},
    {'GitGutterChange', { fg = '#D79921' }},
    {'GitGutterDelete', { fg = '#fb4934' }},

    -- misc
    {'htmlLink', { gui = 'NONE', fg = '#ebdbb2' }},
    {'jsonNoQuotesError', { fg = '#fb4934' }},
    {'jsonMissingCommaError', { fg = '#fb4934' }},
    {'IncSearch', { bg='#282828', fg='#928374' }},
    {'mkdLineBreak', { bg='NONE' }},

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
    {'TelescopeMatching', { bg='NONE', fg='#fb4934', gui='bold' }},
    {'TelescopeBorder', { bg='NONE', fg='#928374', gui='bold' }},

    -- diagnostic nvim
    {'LspDiagnosticsError', { bg='NONE', fg='#fb4934' }},
    {'LspDiagnosticsWarning', { bg='NONE', fg='#D79921' }},
    {'LspDiagnosticsInformation', { bg='NONE', fg='#458588' }},
    {'LspDiagnosticsHint', { bg='NONE', fg='#689D6A' }},

    -- ts override
    {'TSKeywordOperator', { bg='NONE', fg='#fb4934' }},
  }

  for _, highlight in pairs(highlights) do
    hl(highlight[1], highlight[2])
  end
end

ColorUtil.override_eunoia = function()
  local highlights = {
    -- Disable background
    {'Normal', { bg = 'NONE'}},

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
    {'TelescopeSelection', { bg='#2C2941', fg='#dedbd6' }},
    {'TelescopeMatching', { bg='NONE', fg='#FF496F' }},
    {'TelescopeBorder', { bg='#151326', fg='#4D5980' }},
    {'TelescopeNormal', { bg='#151326' }},
  }

  for _, highlight in pairs(highlights) do
    hl(highlight[1], highlight[2])
  end
end

-- italicize comments
hl('Comment', { gui = 'italic' })

-- automatically override colourscheme
vim.cmd('augroup NewColor')
vim.cmd('au!')
vim.cmd('au ColorScheme gruvbox call v:lua.ColorUtil.override_gruvbox()')
vim.cmd('au ColorScheme eunoia call v:lua.ColorUtil.override_eunoia()')
vim.cmd('augroup END')
-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false
vim.cmd('color gruvbox')

-- needs to be loaded after setting colourscheme
require'nvim-web-devicons'.setup {
  override = {
    svg = {
      icon = '',
      color = '#ebdbb2',
      name = 'Svg'
    }
  };
  default = true
}
