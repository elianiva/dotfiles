local Color, _, Group = require'colorbuddy'.setup()
local c = require('colorbuddy.color').colors
local g = require('colorbuddy.group').groups
local s = require('colorbuddy.style').styles

-- {{{ COLOURS DEFINITION
Color.new('eunoia_black', '#151326')
Color.new('eunoia_white', '#dedbd6')

Color.new('eunoia_grey', '#2C2941')
Color.new('eunoia_grey_lighter', '#4D5980')
Color.new('eunoia_grey_light', '#4B5573')
Color.new('eunoia_grey_dark', '#211D35')
Color.new('eunoia_grey_darker', '#1D192E')

Color.new('eunoia_tan', '#FFB55E')

Color.new('eunoia_red', '#FF496F')
Color.new('eunoia_red_dark', '#CC173C')
Color.new('eunoia_red_light', '#FF4356')

Color.new('eunoia_yellow', '#FFE064')
Color.new('eunoia_orange', '#FE5B45')
Color.new('eunoia_orange_light', '#FC9349')

Color.new('eunoia_green', '#44D695')
Color.new('eunoia_green_light', '#51E78C')
Color.new('eunoia_green_dark', '#2CBD80')

Color.new('eunoia_blue', '#6391F4')
Color.new('eunoia_cyan', '#58CDFF')
Color.new('eunoia_ice', '#6370F4')
Color.new('eunoia_teal', '#4EC2D9')
Color.new('eunoia_turqoise', '#2bff99')

Color.new('magenta', '#E36DD4')
Color.new('magenta_dark', '#BE5DC9')
Color.new('eunoia_pink', '#DA6DE3')
Color.new('eunoia_pink_light', '#FFA6FF')
Color.new('eunoia_purple', '#BA6DFF')
Color.new('eunoia_purple_light', '#C874FF')
-- }}}

-- {{{ GENERAL HIGHLIGHTS
-- Text Analysis{{{
Group.new('Normal', c.eunoia_white, c.eunoia_black)
Group.new('Comment', c.eunoia_grey_light, nil, s.italic)
Group.new('NonText', c.eunoia_grey_darker)
Group.new('EndOfBuffer', g.NonText)
Group.new('eunoia_whitespace', g.NonText)
--}}}
-- Helpers{{{
Group.new('Underlined', c.eunoia_cyan, nil, s.underline)
Group.new('Ignore', c.eunoia_grey)
Group.new('Error', c.eunoia_red_dark)
Group.new('Todo', c.eunoia_red_dark, nil, s.bold)
Group.new('helpHyperTextJump', g.Underlined)
Group.new('helpSpecial', c.eunoia_teal)
Group.new('Hint', c.eunoia_green, nil, s.italic)
Group.new('Info', c.eunoia_cyan, nil, s.italic)
Group.new('Warning', c.eunoia_yellow, nil, s.italic)
--}}}
-- Messages{{{
Group.new('ErrorMsg', c.eunoia_red, nil, s.bold)
Group.new('HintMsg', c.eunoia_green, nil, s.bold)
Group.new('InfoMsg', c.eunoia_cyan, nil, s.bold)
Group.new('WarningMsg', c.eunoia_yellow, nil, s.bold)
Group.new('ModeMsg', c.eunoia_blue, nil, s.bold)
Group.new('Question', c.eunoia_orange_light, nil, s.underline)
--}}}
-- Misc{{{
Group.new('ColorColumn', nil, c.eunoia_grey_dark)
Group.new('SignColumn', nil, nil)
Group.new('Directory', c.eunoia_ice, nil, s.bold)
--}}}
-- Literals{{{
Group.new('Constant', c.eunoia_orange_light)
Group.new('String', c.eunoia_green)
Group.new('Character', c.eunoia_red_light)
Group.new('Number', c.eunoia_pink_light)
Group.new('Boolean', c.eunoia_yellow)
Group.new('Float', g.Number)
--}}}
-- Identifiers{{{
Group.new('Identifier', c.eunoia_white)
Group.new('Function', c.eunoia_teal)
--}}}
-- Syntax{{{
Group.new('Statement', c.eunoia_red)
Group.new('Conditional', c.eunoia_ice, nil, s.italic)
Group.new('Repeat', c.eunoia_turqoise)
Group.new('Label', c.eunoia_pink, nil, s.italic)
Group.new('Operator', c.eunoia_orange)
Group.new('Keyword', c.eunoia_red)
Group.new('Exception', c.eunoia_red_light, nil, s.bold)
Group.new('Noise', c.eunoia_white)
--}}}
-- Metatextual Information{{{
Group.new('PreProc', c.eunoia_tan)
Group.new('Include', c.eunoia_cyan, nil)
Group.new('Define', c.eunoia_blue, nil)
Group.new('Macro', c.eunoia_blue, nil, s.italic)
Group.new('PreCondit', c.eunoia_tan, nil, s.italic)
--}}}
-- Semantics{{{
Group.new('Type', c.eunoia_blue)
Group.new('StorageClass', c.eunoia_orange_light)
Group.new('Structure', c.eunoia_cyan)
Group.new('Typedef', c.eunoia_cyan, nil, s.italic)
--}}}
-- Edge Cases{{{
Group.new('Special', c.eunoia_ice)
Group.new('SpecialChar', c.eunoia_red_light, nil, s.italic)
Group.new('SpecialKey', g.Character)
Group.new('Tag', g.Underlined)
Group.new('Delimiter', c.eunoia_white)
Group.new('SpecialComment', c.eunoia_red, nil, s.bold)
Group.new('Debug', g.WarningMsg)
--}}}
-- Editor's UI{{{
Group.new('StatusLine', c.eunoia_white, c.eunoia_grey_darker)
Group.new('StatusLineNC', c.eunoia_grey_light, c.eunoia_grey_darker)
Group.new('StatusLineTerm', g.StatusLine)
Group.new('StatusLineTermNC', g.StatuslineNC)
--}}}
-- Separators{{{
Group.new('VertSplit', c.eunoia_grey, c.eunoia_grey)
Group.new('TabLine', c.eunoia_white, c.eunoia_black)
Group.new('TabLineFill', c.eunoia_white)
Group.new('TabLineSel', c.eunoia_white, c.eunoia_grey_darker)
Group.new('Title', nil, nil, s.bold)
--}}}
-- Conceal{{{
Group.new('CursorLine', nil, c.eunoia_grey_dark)
Group.new('CursorLineNr', c.eunoia_blue, c.eunoia_grey_dark, s.bold)
Group.new('debugBreakpoint', g.ErrorMsg)
Group.new('debugPC', g.ColorColumn)
Group.new('LineNr', g.Comment)
Group.new('QuickFixLine', nil, c.eunoia_grey_darker)
Group.new('Visual', nil, c.eunoia_grey_light)
Group.new('VisualNOS', nil, c.eunoia_grey_darker)
--}}}
-- Pmenu{{{
Group.new('Pmenu', c.eunoia_white, c.eunoia_grey)
Group.new('PmenuSbar', nil, c.eunoia_black)
Group.new('PmenuSel', c.eunoia_black, c.eunoia_blue)
Group.new('PmenuThumb', nil, c.eunoia_grey)
Group.new('WildMenu', c.eunoia_black, c.eunoia_blue)
--}}}
-- Folds{{{
Group.new('FoldColumn', nil, c.eunoia_grey_dark, s.bold)
Group.new('Folded', c.eunoia_grey_lighter, c.eunoia_grey_dark)
--}}}
-- Diffs{{{
Group.new('DiffAdd', c.eunoia_green, nil)
Group.new('DiffChange', c.eunoia_orange, nil)
Group.new('DiffDelete', c.eunoia_red, nil)
Group.new('DiffText', c.eunoia_white, nil)
--}}}
-- Searching{{{
Group.new('IncSearch', c.eunoia_black, c.eunoia_grey_light)
Group.new('Substitute', c.eunoia_black, c.eunoia_grey_light)
Group.new('Search', c.eunoia_white, nil, s.underline)
Group.new('MatchParen', c.eunoia_green, nil, s.underline + s.bold)
--}}}
-- Spelling{{{
Group.new('SpellBad', c.eunoia_red, nil, s.underline)
Group.new('SpellCap', c.eunoia_yellow, nil, s.underline)
Group.new('SpellLocal', c.eunoia_green, nil, s.underline)
Group.new('SpellRare', c.eunoia_orange_light, nil, s.underline)
--}}}
-- LuaTree{{{
Group.new('LuaTreeDirty', g.Error)

-- LSP
Group.new('LspDiagnosticsError', g.Error)
Group.new('LspDiagnosticsErrorFloating', g.ErrorMsg)
Group.new('LspDiagnosticsErrorSign', g.ErrorMsg)

Group.new('LspDiagnosticsWarning', g.Warning)
Group.new('LspDiagnosticsWarningFloating', g.WarningMsg)
Group.new('LspDiagnosticsWarningSign', g.WarningMsg)

Group.new('LspDiagnosticsHint', g.Hint)
Group.new('LspDiagnosticsHintFloating', g.HintMsg)
Group.new('LspDiagnosticsHintSign', g.HintMsg)

Group.new('LspDiagnosticsHint', g.Hint)
Group.new('LspDiagnosticsHintFloating', g.HintMsg)
Group.new('LspDiagnosticsHintSign', g.HintMsg)

Group.new('LspDiagnosticsInformation', g.Info)
Group.new('LspDiagnosticsInformationFloating', g.InfoMsg)
Group.new('LspDiagnosticsInformationSign', g.InfoMsg)

Group.new('LspDiagnosticsUnderline', nil, nil, s.underline)
Group.new('LspDiagnosticsUnderlineError', nil, nil, s.underline)
Group.new('LspDiagnosticsUnderlineHint', nil, nil, s.underline)
Group.new('LspDiagnosticsUnderlineInfo', nil, nil, s.underline)
Group.new('LspDiagnosticsUnderlineWarning', nil, nil, s.underline)
--}}}
-- Cursor{{{
Group.new('Cursor', nil, nil)
Group.new('CursorIM', g.Cursor)
Group.new('CursorColumn', nil, c.eunoia_grey_dark)
--}}}
-- }}}

-- {{{ LANGUAGES
-- CSS{{{
Group.new('cssBraces', g.Delimiter)
Group.new('cssProp', g.Keyword)
Group.new('cssSelectorOp', g.Operator)
Group.new('cssTagName', g.Type)
Group.new('cssClassName', c.eunoia_tan)
Group.new('cssClassName', c.eunoia_tan)
Group.new('cssValueNumber', g.Constant)
Group.new('cssValueLength', g.Constant)
Group.new('cssAttr', g.Constant)
Group.new('cssPositioningAttr', g.Constant)
Group.new('cssFlexibleBoxAttr', g.Constant)
Group.new('scssAmpersand', g.Special)
Group.new('scssAttribute', g.Label)
Group.new('scssBoolean', g.Boolean)
Group.new('scssDefault', g.Keyword)
Group.new('scssElse', g.PreCondit)
Group.new('scssIf', g.PreCondit)
Group.new('scssInclude', g.Include)
Group.new('scssSelectorChar', g.Operator)
Group.new('scssSelectorName', g.Identifier)
Group.new('scssVariable', g.Define)
Group.new('scssVariableAssignment', g.Operator)
--}}}
-- HTML{{{
Group.new('htmlArg', c.eunoia_orange_light)
Group.new('htmlAttr', c.eunoia_orange_light)
Group.new('htmlBold', c.eunoia_grey_light, nil, s.bold)
Group.new('htmlTitle', c.eunoia_white, nil, s.bold)
Group.new('htmlEndTag', g.Tag)
Group.new('htmlH1', c.eunoia_white, nil, s.bold)
Group.new('htmlH2', c.eunoia_white, nil, s.bold)
Group.new('htmlH3', c.eunoia_white, nil, s.bold)
Group.new('htmlH4', c.eunoia_white, nil, s.bold)
Group.new('htmlH5', c.eunoia_white, nil, s.bold)
Group.new('htmlH6', c.eunoia_white, nil, s.bold)
Group.new('htmlItalic', c.eunoia_white, nil, s.italic)
Group.new('htmlTagName', c.eunoia_red, nil)
Group.new('htmlScriptTag', c.eunoia_red, nil)
Group.new('htmlSpecialTagName', g.htmlTagName)
Group.new('htmlSpecialChar', c.eunoia_red)
Group.new('htmlLink', c.eunoia_white, nil)
--}}}
-- Javascript{{{
Group.new('javascriptBraces', c.eunoia_white)
Group.new('javascriptFunction', g.Function)
Group.new('javascriptIdentifier', g.Identifier)
Group.new('javascriptMember', c.eunoia_blue)
Group.new('javascriptNumber', g.Number)
Group.new('javascriptNull', g.Constant)
Group.new('javascriptParens', c.eunoia_white)
Group.new('javascriptImport', c.eunoia_ice)
Group.new('javascriptExport', c.eunoia_ice)
Group.new('javascriptClassKeyword', c.eunoia_ice)
Group.new('javascriptClassExtends', c.eunoia_ice)
Group.new('javascriptDefault', c.eunoia_ice)

Group.new('javascriptClassName', c.eunoia_red)
Group.new('javascriptClassSuperName', c.eunoia_yellow)
Group.new('javascriptGlobal', c.eunoia_yellow)

Group.new('javascriptEndColons', c.eunoia_white)
Group.new('javascriptFuncArg', c.eunoia_white)
Group.new('javascriptGlobalMethod', c.eunoia_white)
Group.new('javascriptNodeGlobal', c.eunoia_white)
Group.new('javascriptBOMWindowProp', c.eunoia_white)
Group.new('javascriptArrayMethod', c.eunoia_white)
Group.new('javascriptArrayStaticMethod', c.eunoia_white)
Group.new('javascriptCacheMethod', c.eunoia_white)
Group.new('javascriptDateMethod', c.eunoia_white)
Group.new('javascriptMathStaticMethod', c.eunoia_white)
Group.new('javascriptURLUtilsProp', c.eunoia_white)
Group.new('javascriptBOMNavigatorProp', c.eunoia_white)
Group.new('javascriptDOMDocMethod', c.eunoia_white)
Group.new('javascriptDOMDocProp', c.eunoia_white)
Group.new('javascriptBOMLocationMethod', c.eunoia_white)
Group.new('javascriptBOMWindowMethod', c.eunoia_white)
Group.new('javascriptStringMethod', c.eunoia_white)

Group.new('javascriptVariable', g.Identifier)
Group.new('javascriptIdentifier', g.Identifier)
Group.new('javascriptClassSuper', c.eunoia_orange)

Group.new('javascriptFuncKeyword', c.eunoia_ice)
Group.new('javascriptAsyncFunc', c.eunoia_red)
Group.new('javascriptClassStatic', c.eunoia_orange)

Group.new('javascriptOperator', c.eunoia_red)
Group.new('javascriptForOperator', g.Repeat)
Group.new('javascriptYield', c.eunoia_red)
Group.new('javascriptExceptions', g.Exception)
Group.new('javascriptMessage', c.eunoia_red)

Group.new('javascriptTemplateSB', c.eunoia_cyan)
Group.new('javascriptTemplateSubstitution', c.eunoia_white)
Group.new('javascriptLabel', g.Label)
Group.new('javascriptObjectLabel', g.Label)
Group.new('javascriptPropertyName', g.Label)

Group.new('javascriptLogicSymbols', c.eunoia_white)
Group.new('javascriptArrowFunc', c.eunoia_yellow)

Group.new('javascriptDocParamName', c.eunoia_cyan)
Group.new('javascriptDocTags', c.eunoia_white)
Group.new('javascriptDocNotation', c.eunoia_red)
Group.new('javascriptDocParamType', c.eunoia_ice)
Group.new('javascriptDocNamedParamType', c.eunoia_ice)

Group.new('javascriptBrackets', c.eunoia_white)
Group.new('javascriptDOMElemAttrs', c.eunoia_white)
Group.new('javascriptDOMEventMethod', c.eunoia_white)
Group.new('javascriptDOMNodeMethod', c.eunoia_white)
Group.new('javascriptDOMStoragemethod', c.eunoia_white)
Group.new('javascriptDOMHeadersMethod', c.eunoia_white)

Group.new('javascriptAsyncFuncKeyword', c.eunoia_red)
Group.new('javascriptAwaitFuncKeyword', c.eunoia_red)

Group.new('jsClassKeyword', c.eunoia_ice)
Group.new('jsExtendsKeyword', c.eunoia_ice)
Group.new('jsExportDefault', c.eunoia_ice)
Group.new('jsTemplateBraces', c.eunoia_ice)
Group.new('jsGlobalNodeObjects', c.eunoia_blue)
Group.new('jsGlobalObjects', c.eunoia_blue)
Group.new('jsObjectKey', c.eunoia_cyan, nil, s.bold)
Group.new('jsFunction', c.eunoia_blue)
Group.new('jsFuncCall', c.eunoia_blue)
Group.new('jsFuncParens', c.eunoia_blue)
Group.new('jsParens', c.eunoia_white)
Group.new('jsNull', g.Constant)
Group.new('jsUndefined', g.Constant)
Group.new('jsClassDefinition', c.eunoia_yellow)
Group.new('jsOperatorKeyword', c.eunoia_red)
Group.new('jsStorageClass', c.eunoia_red)
Group.new('jsRegexpOr', c.eunoia_ice)
--}}}
-- Typescript{{{
Group.new('typescriptReserved', c.eunoia_ice)
Group.new('typescriptLabel', g.Label)
Group.new('typescriptFuncKeyword', c.eunoia_red)
Group.new('typescriptIdentifier', g.Identifier)
Group.new('typescriptBraces', c.eunoia_white)
Group.new('typescriptEndColons', c.eunoia_white)
Group.new('typescriptDOMObjects', c.eunoia_white)
Group.new('typescriptAjaxMethods', c.eunoia_white)
Group.new('typescriptLogicSymbols', c.eunoia_white)
Group.new('typescriptDocSeeTag', c.eunoia_cyan)
Group.new('typescriptDocParam', c.eunoia_red)
Group.new('typescriptDocTags', c.eunoia_blue)
Group.new('typescriptGlobalObjects', c.eunoia_white)
Group.new('typescriptParens', c.eunoia_white)
Group.new('typescriptOpSymbols', c.eunoia_white)
Group.new('typescriptHtmlElemProperties', c.eunoia_white)
Group.new('typescriptNull', g.Constant)
Group.new('typescriptInterpolationDelimiter', c.eunoia_ice)
--}}}
-- JSX{{{
Group.new('jsxTagName', c.eunoia_green)
Group.new('jsxComponentName', c.eunoia_green)
Group.new('jsxCloseString', c.eunoia_white)
Group.new('jsxAttrib', c.eunoia_orange)
Group.new('jsxEqual', c.eunoia_turqoise)
--}}}
-- JSON{{{
Group.new('jsonBraces', g.Structure)
Group.new('jsonKeywordMatch', g.Operator)
Group.new('jsonNull', g.Constant)
Group.new('jsonQuote', g.Delimiter)
Group.new('jsonString', g.String)
Group.new('jsonStringSQError', g.Exception)
--}}}
-- LUA{{{
Group.new('luaBraces', g.Structure)
Group.new('luaBrackets', g.Delimiter)
Group.new('luaBuiltin', g.Keyword)
Group.new('luaComma', g.Delimiter)
Group.new('luaFunction', g.Function)
Group.new('luaFuncArgName', g.Identifier)
Group.new('luaFunctionCall', c.eunoia_blue)
Group.new('luaFuncId', g.Operator)
Group.new('luaFuncKeyword', g.Type)
Group.new('luaFuncName', g.Function)
Group.new('luaFuncParens', g.Delimiter)
Group.new('luaFuncTable', g.Structure)
Group.new('luaLocal', g.Type)
Group.new('luaNoise', g.Operator)
Group.new('luaParens', g.Delimiter)
Group.new('luaSpecialTable', g.StorageClass)
Group.new('luaSpecialValue', g.Function)
Group.new('luaIdentifier', g.Identifier)
Group.new('luaConstant', g.Constant)
Group.new('luaReturn', c.eunoia_cyan, nil, s.italic)
Group.new('luaStatement', c.eunoia_ice)
--}}}
-- Markdown{{{
Group.new('markdownH1', g.htmlH1)
Group.new('markdownH2', g.htmlH2)
Group.new('markdownH3', g.htmlH3)
Group.new('markdownH4', g.htmlH4)
Group.new('markdownH5', g.htmlH5)
Group.new('markdownH6', g.htmlH6)
Group.new('mkdBold', g.SpecialComment)
Group.new('mkdCode', g.Keyword)
Group.new('mkdCodeDelimiter', g.mkdBold)
Group.new('mkdCodeStart', g.mkdCodeDelimiter)
Group.new('mkdCodeEnd', g.mkdCodeStart)
Group.new('mkdHeading', c.eunoia_white, nil, s.bold)
Group.new('mkdItalic', c.eunoia_white, nil, s.italic)
Group.new('mkdListItem', g.Special)
Group.new('mkdRule', g.Underlined)
--}}}
-- Rust{{{
Group.new('rustKeyword', g.Keyword)
Group.new('rustModPath', g.Include)
Group.new('rustScopeDecl', g.Delimiter)
Group.new('rustTrait', g.StorageClass)
--}}}
-- VimL{{{
Group.new('vimNotation', c.eunoia_orange)
Group.new('vimBracket', c.eunoia_orange)
Group.new('vimMapModKey', c.eunoia_orange)
Group.new('vimNotFunc', c.eunoia_ice)
Group.new('vimCommand', g.vimNotFunc)
Group.new('vimFuncSID', c.eunoia_white)
Group.new('vimUserFunc', c.eunoia_cyan)
Group.new('vimSetSep', c.eunoia_white)
Group.new('vimSep', c.eunoia_white)
Group.new('vimContinue', c.eunoia_white)
Group.new('vimAbb', c.eunoia_blue)
Group.new('vimMapLhs', c.eunoia_yellow)
--}}}
-- Java{{{
Group.new('javaAnnotation', c.eunoia_blue)
Group.new('javaDocTags', c.eunoia_ice)
Group.new('javaCommentTitle', c.eunoia_white, nil, s.italic + s.bold)
Group.new('javaParen', c.eunoia_white)
Group.new('javaParen1', c.eunoia_white)
Group.new('javaParen2', c.eunoia_white)
Group.new('javaParen3', c.eunoia_white)
Group.new('javaParen4', c.eunoia_white)
Group.new('javaParen5', c.eunoia_white)
Group.new('javaOperator', c.eunoia_cyan)
Group.new('javaVarArg', c.eunoia_red)
--}}}
-- Xresources{{{
Group.new('xdefaultsValue', c.eunoia_white)
--}}}
-- SQL {{{
Group.new('sqlKeyword', c.eunoia_red)
--}}}
-- }}}

-- PLUGINS {{{
-- Signify{{{
Group.new('SignifySignAdd', c.eunoia_green)
Group.new('SignifySignChange', c.eunoia_orange)
Group.new('SignifySignDelete', c.eunoia_red)
Group.new('SignifySignChangeDelete', c.eunoia_orange_light)
--}}}
-- Treesitter {{{
Group.new('TSBoolean', g.Boolean)
Group.new('TSConstBuiltin', g.Constant)
Group.new('TSConstMacro', g.Constant)
Group.new('TSConstructor', g.Function)
Group.new('TSFuncBuiltin', g.Function)
Group.new('TSString', g.String)
Group.new('TSCharacter', g.String)
Group.new('TSConditional', g.String)
Group.new('TSError', g.Error)
Group.new('TSNumber', g.Number)
Group.new('TSFloat', g.Float)
Group.new('TSLabel', g.Label)
Group.new('TSFunction', g.Function)
Group.new('TSStringEscape', g.Character)
Group.new('TSStringRegex', g.SpecialChar)
Group.new('TSPunctDelimiter', g.Delimiter)
Group.new('TSPunctBracket', c.eunoia_white)
Group.new('TSParameter', c.eunoia_orange)
Group.new('TSParameterReference', c.eunoia_orange)
Group.new('TSRepeat', g.Repeat)
Group.new('TSOperator', g.Operator)
Group.new('TSKeyword', g.Keyword)
Group.new('TSKeywordFunction', g.Function)
Group.new('TSMethod', g.Function)
Group.new('TSURI', g.Tag)
Group.new('TSType', c.eunoia_ice)
Group.new('TSTypeBuiltin', c.eunoia_tan)
Group.new('TSNamespace', c.eunoia_orange)
Group.new('TSInclude', c.eunoia_cyan)
Group.new('TSText', c.eunoia_white)
Group.new('TSTitle', c.eunoia_white, nil, s.bold)
Group.new('TSStrong', c.eunoia_red, nil, s.bold)
Group.new('TSEmphasis', c.eunoia_ice, nil, s.italic)
Group.new('TSUnderline', c.eunoia_ice, nil, s.underline)
Group.new('TSSpecial', c.eunoia_ice)
Group.new('TSProperty', c.eunoia_blue)
Group.new('TSVariable', g.Identifier)
Group.new('TSVariableBuiltin', g.Identifier)
--}}}
-- Bufferline.nvim {{{
Group.new('BufferLineSelected', c.eunoia_white, c.eunoia_black, s.bold)
Group.new('BufferLineTabSelectedSeparator', c.eunoia_blue)
Group.new('BufferLineFill', nil, c.eunoia_grey_darker)
Group.new('BufferLineBackground', nil, c.eunoia_grey_darker)
Group.new('BufferLineInactive', nil, c.eunoia_grey_darker)
--}}}
--}}}

-- vim: foldmethod=marker
