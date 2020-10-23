-- vim: set sw=2 ts=2 sts=2 et tw=80 ft=lua fdm=marker:

local Color, colors, Group, groups, styles = require('colorbuddy').setup()

-- define colours
Color.new('background', '#272C41')
Color.new('foreground', '#FEFDF9')
Color.new('white',      '#FEFDF9')
Color.new('red',        '#D55355')
Color.new('green',      '#41E0AB')
Color.new('yellow',     '#FBFE8A')
Color.new('orange',     '#FF9552')
Color.new('blue',       '#5881CA')
Color.new('cyan',       '#9DC9E5')
Color.new('magenta',    '#AA6FFF')
Color.new('purple',     '#8D5DFF')
Color.new('grey',       '#333842')
Color.new('lightgrey',  '#969896')

-- vanilla colorscheme
-- GENERAL UI: {{{
Color.new('Normal', colors.foreground, colors.background)
Color.new('CursorLine', nil, colors.grey)
Color.new('TabLineFill', colors.foreground, colors.grey)
Color.new('TabLineSel', colors.blue, colors.background)
-- }}}
-- SYNTAX HL: {{{
Group.new('Comment', colors.lightgrey, nil, styles.italic)
Group.new('Statement', colors.red)
Group.new('Repeat', colors.red)
Group.new('Label', colors.red)
Group.new('Exception', colors.red)
Group.new('Operator', colors.foreground)
Group.new('Keyword', colors.orange)
Group.new('Identifier', colors.blue)
Group.new('Function', colors.blue, nil, styles.bold)
Group.new('Prepoc', colors.cyan)
Group.new('Include', colors.cyan)
Group.new('Define', colors.cyan)
Group.new('Constant', colors.magenta)
Group.new('Character', colors.purple)
Group.new('String', colors.green)
Group.new('Boolean', colors.red)
Group.new('Number', colors.cyan)
Group.new('Float', colors.magenta)
Group.new('Type', colors.orange)
Group.new('StorageClass', colors.orange)
Group.new('Structure', colors.orange)
Group.new('Typedef', colors.orange)
-- }}}
-- COMPLETION: {{{
Group.new('Pmenu', colors.lightgrey, colors.grey)
Group.new('PmenuSel', colors.background, colors.red, styles.bold)
Group.new('PmenuSbar', nil, colors.grey)
Group.new('PmenuThumb', nil, colors.grey)
-- }}}
-- GUTTER: {{{
Group.new('LineNr', colors.lightgrey, nil)
Group.new('SignColumn', colors.lightgrey, nil)
Group.new('Folded', colors.lightgrey, colors.grey, styles.italic)
Group.new('FoldColumn', colors.lightgrey, colors.grey, styles.italic)
-- }}}
-- CURSOR: {{{
Group.new('Cursor', nil, nil)
Group.new('vCursor', g.Cursor)
Group.new('iCursor', g.Cursor)
Group.new('lCursor', g.Cursor)
-- }}}

-- filetype specific
-- HTML: {{{
Group.new('htmlTag', colors.cyan)
-- }}}
-- LUA: {{{
Group.new('luaIn', colors.red)
Group.new('luaFunction', colors.cyan)
Group.new('luaTable', colors.red)
-- }}}
-- TYPESCRIPT: {{{
Group.new('typescriptReserved', colors.cyan)
Group.new('typescriptLabel', colors.cyan)
Group.new('typescriptInterfaceKeyword', colors.red)
Group.new('typescriptFuncKeyword', colors.red)
Group.new('typescriptVariable', colors.red)
Group.new('typescriptIdentifier', colors.orange)
Group.new('typescriptBraces', colors.foreground)
Group.new('typescriptEndColons', colors.foreground)
Group.new('typescriptDOMObjects', colors.foreground)
Group.new('typescriptAjaxMethods', colors.foreground)
Group.new('typescriptLogicSymbols', colors.foreground)
Group.new('typescriptDocSeeTag', g.Comment, nil, styles.italic)
Group.new('typescriptDocParam', colors.orange, nil, styles.italic)
Group.new('typescriptDocTags', colors.red, nil, styles.italic)
Group.new('typescriptDocNotation', colors.red, nil, styles.italic)
Group.new('typescriptDocNamedParamType', colors.orange, nil, styles.italic)
Group.new('typescriptGlobalObjects', colors.aqua)
Group.new('typescriptString', colors.green)
-- }}}
-- JAVASCRIPT: {{{
Group.new('jsClassKeyword', colors.aqua)
Group.new('jsClassKeyword', colors.aqua)
-- }}}
-- DIFF: {{{
Group.new('DiffDelete', colors.background, colors.red)
Group.new('DiffAdd', colors.background, colors.green)
Group.new('DiffChange', colors.background, colors.blue)
Group.new('DiffText', colors.background, colors.yellow)
-- }}}
-- VIM: {{{
Group.new('vimCommentTitle', colors.red)
Group.new('vimNotation', colors.orange)
Group.new('vimBracket', colors.orange)
Group.new('vimMapModKey', colors.orange)
Group.new('vimFuncSID', colors.purple)
Group.new('vimSetSep', colors.red)
Group.new('vimSep', colors.red)
Group.new('vimContinue', colors.blue)
-- }}}
-- CSS: {{{
Group.new('cssBraces', colors.blue)
Group.new('cssFunctionName', colors.yellow)
Group.new('cssIdentifier', colors.orange)
Group.new('cssClassName', colors.red)
-- }}}
-- JSX: {{{
Group.new('jsxTagName', colors.orange)
Group.new('jsxComponentName', colors.green)
Group.new('jsxCloseString', colors.foreground)
Group.new('jsxAttrib', colors.red)
Group.new('jsxEqual', colors.cyan)
-- }}}
