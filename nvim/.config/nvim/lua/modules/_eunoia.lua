local Color, _, Group = require'colorbuddy'.setup()
local c = require('colorbuddy.color').colors
local g = require('colorbuddy.group').groups
local s = require('colorbuddy.style').styles

local M = {}

function M:setup()
  vim.cmd('hi! clear')

  M:define_colours()
  M:general_highlights()
  M:lsp_highlights()
  M:languages_highlights()
  M:plugins_highlights()
  M:treesitter_highlights()
end

function M:define_colours()
  Color.new('black', '#151326')
  Color.new('white', '#dedbd6')

  Color.new('grey', '#2C2941')
  Color.new('grey_lighter', '#4D5980')
  Color.new('grey_light', '#4B5573')
  Color.new('grey_dark', '#211D35')
  Color.new('grey_darker', '#1D192E')

  Color.new('tan', '#FFB55E')

  Color.new('red', '#FF496F')
  Color.new('red_dark', '#CC173C')
  Color.new('red_light', '#FF4356')

  Color.new('yellow', '#F1DC49')
  Color.new('orange', '#FE5B45')
  Color.new('orange_light', '#FC9349')

  Color.new('green', '#44D695')

  Color.new('blue', '#6391F4')
  Color.new('cyan', '#58CDFF')
  Color.new('ice', '#6370F4')
  Color.new('teal', '#4EC2D9')
  Color.new('turqoise', '#2bff99')

  Color.new('magenta', '#E36DD4')
  Color.new('magenta_dark', '#BE5DC9')
  Color.new('pink', '#DA6DE3')
  Color.new('pink_light', '#FFA6FF')
  Color.new('purple', '#BA6DFF')
  Color.new('purple_light', '#C874FF')
end

function M:general_highlights()
  -- General
  Group.new('Normal', c.white, c.black)
  Group.new('Comment', c.grey_light, nil, s.italic)
  Group.new('NonText', c.grey_darker)
  Group.new('EndOfBuffer', g.NonText)
  Group.new('whitespace', g.NonText)

  -- Helpers
  Group.new('Underlined', c.cyan, nil, s.underline)
  Group.new('Ignore', c.grey)
  Group.new('Error', c.red_dark)
  Group.new('Todo', c.red_dark, nil, s.bold)
  Group.new('helpHyperTextJump', g.Underlined)
  Group.new('helpSpecial', c.teal)
  Group.new('Hint', c.green, nil, s.italic)
  Group.new('Info', c.cyan, nil, s.italic)
  Group.new('Warning', c.yellow, nil, s.italic)

  -- Messages
  Group.new('ErrorMsg', c.red, nil, s.bold)
  Group.new('HintMsg', c.green, nil, s.bold)
  Group.new('InfoMsg', c.cyan, nil, s.bold)
  Group.new('WarningMsg', c.yellow, nil, s.bold)
  Group.new('ModeMsg', c.blue, nil, s.bold)
  Group.new('Question', c.orange_light, nil, s.underline)

  -- Misc
  Group.new('ColorColumn', nil, c.grey_dark)
  Group.new('SignColumn', nil, nil)
  Group.new('Directory', c.ice, nil, s.bold)

  -- Literals
  Group.new('Constant', c.orange_light)
  Group.new('String', c.green)
  Group.new('Character', c.red_light)
  Group.new('Number', c.pink_light)
  Group.new('Boolean', c.yellow)
  Group.new('Float', g.Number)

  -- Identifiers
  Group.new('Identifier', c.white)
  Group.new('Function', c.teal)

  -- Syntax
  Group.new('Statement', c.red)
  Group.new('Conditional', c.ice, nil, s.italic)
  Group.new('Repeat', c.turqoise)
  Group.new('Label', c.pink, nil, s.italic)
  Group.new('Operator', c.orange)
  Group.new('Keyword', c.red)
  Group.new('Exception', c.red_light, nil, s.bold)
  Group.new('Noise', c.white)

  -- Metatextual Information
  Group.new('PreProc', c.tan)
  Group.new('Include', c.cyan, nil)
  Group.new('Define', c.blue, nil)
  Group.new('Macro', c.blue, nil, s.italic)
  Group.new('PreCondit', c.tan, nil, s.italic)

  -- Semantics
  Group.new('Type', c.blue)
  Group.new('StorageClass', c.orange_light)
  Group.new('Structure', c.cyan)
  Group.new('Typedef', c.cyan, nil, s.italic)

  -- Edge Cases
  Group.new('Special', c.ice)
  Group.new('SpecialChar', c.red_light, nil, s.italic)
  Group.new('SpecialKey', g.Character)
  Group.new('Tag', g.Underlined)
  Group.new('Delimiter', c.white)
  Group.new('SpecialComment', c.red, nil, s.bold)
  Group.new('Debug', g.WarningMsg)

  -- Editor's UI
  Group.new('StatusLine', c.white, c.grey_darker)
  Group.new('StatusLineNC', c.grey_light, c.grey_darker)
  Group.new('StatusLineTerm', g.StatusLine)
  Group.new('StatusLineTermNC', g.StatuslineNC)

  -- Separators
  Group.new('VertSplit', c.grey, c.grey)
  Group.new('TabLine', c.white, c.black)
  Group.new('TabLineFill', c.white)
  Group.new('TabLineSel', c.white, c.grey_darker)
  Group.new('Title', nil, nil, s.bold)

  -- Conceal
  Group.new('CursorLine', nil, c.grey_dark)
  Group.new('CursorLineNr', c.blue, c.grey_dark, s.bold)
  Group.new('debugBreakpoint', g.ErrorMsg)
  Group.new('debugPC', g.ColorColumn)
  Group.new('LineNr', g.Comment)
  Group.new('QuickFixLine', nil, c.grey_darker)
  Group.new('Visual', nil, c.grey_light)
  Group.new('VisualNOS', nil, c.grey_darker)

  -- Pmenu
  Group.new('Pmenu', c.white, c.grey)
  Group.new('PmenuSbar', nil, c.black)
  Group.new('PmenuSel', c.black, c.blue)
  Group.new('PmenuThumb', nil, c.grey)
  Group.new('WildMenu', c.black, c.blue)

  -- Folds
  Group.new('FoldColumn', nil, c.grey_dark, s.bold)
  Group.new('Folded', c.grey_lighter, c.grey_dark)

  -- Diffs
  Group.new('DiffAdd', c.green, nil)
  Group.new('DiffChange', c.orange, nil)
  Group.new('DiffDelete', c.red, nil)
  Group.new('DiffText', c.white, nil)

  -- Searching
  Group.new('IncSearch', c.black, c.grey_light)
  Group.new('Substitute', c.black, c.grey_light)
  Group.new('Search', c.white, nil, s.underline)
  Group.new('MatchParen', c.green, nil, s.underline + s.bold)

  -- Spelling
  Group.new('SpellBad', c.red, nil, s.underline)
  Group.new('SpellCap', c.yellow, nil, s.underline)
  Group.new('SpellLocal', c.green, nil, s.underline)
  Group.new('SpellRare', c.orange_light, nil, s.underline)

  -- Cursor
  Group.new('Cursor', nil, nil)
  Group.new('CursorIM', g.Cursor)
  Group.new('CursorColumn', nil, c.grey_dark)
end

function M:lsp_highlights()
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
end

function M:languages_highlights()
  -- CSS
  Group.new('cssBraces', g.Delimiter)
  Group.new('cssProp', g.Keyword)
  Group.new('cssSelectorOp', g.Operator)
  Group.new('cssTagName', g.Type)
  Group.new('cssClassName', c.tan)
  Group.new('cssClassName', c.tan)
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

  -- HTML
  Group.new('htmlArg', c.orange_light)
  Group.new('htmlAttr', c.orange_light)
  Group.new('htmlBold', c.grey_light, nil, s.bold)
  Group.new('htmlTitle', c.white, nil, s.bold)
  Group.new('htmlEndTag', g.Tag)
  Group.new('htmlH1', c.white, nil, s.bold)
  Group.new('htmlH2', c.white, nil, s.bold)
  Group.new('htmlH3', c.white, nil, s.bold)
  Group.new('htmlH4', c.white, nil, s.bold)
  Group.new('htmlH5', c.white, nil, s.bold)
  Group.new('htmlH6', c.white, nil, s.bold)
  Group.new('htmlItalic', c.white, nil, s.italic)
  Group.new('htmlTagName', c.red, nil)
  Group.new('htmlScriptTag', c.red, nil)
  Group.new('htmlSpecialTagName', g.htmlTagName)
  Group.new('htmlSpecialChar', c.red)
  Group.new('htmlLink', c.white, nil)

  -- Javascript
  Group.new('javascriptBraces', c.white)
  Group.new('javascriptFunction', g.Function)
  Group.new('javascriptIdentifier', g.Identifier)
  Group.new('javascriptMember', c.blue)
  Group.new('javascriptNumber', g.Number)
  Group.new('javascriptNull', g.Constant)
  Group.new('javascriptParens', c.white)
  Group.new('javascriptImport', c.ice)
  Group.new('javascriptExport', c.ice)
  Group.new('javascriptClassKeyword', c.ice)
  Group.new('javascriptClassExtends', c.ice)
  Group.new('javascriptDefault', c.ice)

  Group.new('javascriptClassName', c.red)
  Group.new('javascriptClassSuperName', c.yellow)
  Group.new('javascriptGlobal', c.yellow)

  Group.new('javascriptEndColons', c.white)
  Group.new('javascriptFuncArg', c.white)
  Group.new('javascriptGlobalMethod', c.white)
  Group.new('javascriptNodeGlobal', c.white)
  Group.new('javascriptBOMWindowProp', c.white)
  Group.new('javascriptArrayMethod', c.white)
  Group.new('javascriptArrayStaticMethod', c.white)
  Group.new('javascriptCacheMethod', c.white)
  Group.new('javascriptDateMethod', c.white)
  Group.new('javascriptMathStaticMethod', c.white)
  Group.new('javascriptURLUtilsProp', c.white)
  Group.new('javascriptBOMNavigatorProp', c.white)
  Group.new('javascriptDOMDocMethod', c.white)
  Group.new('javascriptDOMDocProp', c.white)
  Group.new('javascriptBOMLocationMethod', c.white)
  Group.new('javascriptBOMWindowMethod', c.white)
  Group.new('javascriptStringMethod', c.white)

  Group.new('javascriptVariable', g.Identifier)
  Group.new('javascriptIdentifier', g.Identifier)
  Group.new('javascriptClassSuper', c.orange)

  Group.new('javascriptFuncKeyword', c.ice)
  Group.new('javascriptAsyncFunc', c.red)
  Group.new('javascriptClassStatic', c.orange)

  Group.new('javascriptOperator', c.red)
  Group.new('javascriptForOperator', g.Repeat)
  Group.new('javascriptYield', c.red)
  Group.new('javascriptExceptions', g.Exception)
  Group.new('javascriptMessage', c.red)

  Group.new('javascriptTemplateSB', c.cyan)
  Group.new('javascriptTemplateSubstitution', c.white)
  Group.new('javascriptLabel', g.Label)
  Group.new('javascriptObjectLabel', g.Label)
  Group.new('javascriptPropertyName', g.Label)

  Group.new('javascriptLogicSymbols', c.white)
  Group.new('javascriptArrowFunc', c.yellow)

  Group.new('javascriptDocParamName', c.cyan)
  Group.new('javascriptDocTags', c.white)
  Group.new('javascriptDocNotation', c.red)
  Group.new('javascriptDocParamType', c.ice)
  Group.new('javascriptDocNamedParamType', c.ice)

  Group.new('javascriptBrackets', c.white)
  Group.new('javascriptDOMElemAttrs', c.white)
  Group.new('javascriptDOMEventMethod', c.white)
  Group.new('javascriptDOMNodeMethod', c.white)
  Group.new('javascriptDOMStoragemethod', c.white)
  Group.new('javascriptDOMHeadersMethod', c.white)

  Group.new('javascriptAsyncFuncKeyword', c.red)
  Group.new('javascriptAwaitFuncKeyword', c.red)

  Group.new('jsClassKeyword', c.ice)
  Group.new('jsExtendsKeyword', c.ice)
  Group.new('jsExportDefault', c.ice)
  Group.new('jsTemplateBraces', c.ice)
  Group.new('jsGlobalNodeObjects', c.blue)
  Group.new('jsGlobalObjects', c.blue)
  Group.new('jsObjectKey', c.cyan, nil, s.bold)
  Group.new('jsFunction', c.blue)
  Group.new('jsFuncCall', c.blue)
  Group.new('jsFuncParens', c.blue)
  Group.new('jsParens', c.white)
  Group.new('jsNull', g.Constant)
  Group.new('jsUndefined', g.Constant)
  Group.new('jsClassDefinition', c.yellow)
  Group.new('jsOperatorKeyword', c.red)
  Group.new('jsStorageClass', c.red)
  Group.new('jsRegexpOr', c.ice)

  -- Typescript
  Group.new('typescriptReserved', c.ice)
  Group.new('typescriptLabel', g.Label)
  Group.new('typescriptFuncKeyword', c.red)
  Group.new('typescriptIdentifier', g.Identifier)
  Group.new('typescriptBraces', c.white)
  Group.new('typescriptEndColons', c.white)
  Group.new('typescriptDOMObjects', c.white)
  Group.new('typescriptAjaxMethods', c.white)
  Group.new('typescriptLogicSymbols', c.white)
  Group.new('typescriptDocSeeTag', c.cyan)
  Group.new('typescriptDocParam', c.red)
  Group.new('typescriptDocTags', c.blue)
  Group.new('typescriptGlobalObjects', c.white)
  Group.new('typescriptParens', c.white)
  Group.new('typescriptOpSymbols', c.white)
  Group.new('typescriptHtmlElemProperties', c.white)
  Group.new('typescriptNull', g.Constant)
  Group.new('typescriptInterpolationDelimiter', c.ice)

  -- JSX
  Group.new('jsxTagName', c.green)
  Group.new('jsxComponentName', c.green)
  Group.new('jsxCloseString', c.white)
  Group.new('jsxAttrib', c.orange)
  Group.new('jsxEqual', c.turqoise)

  -- JSON
  Group.new('jsonBraces', g.Structure)
  Group.new('jsonKeywordMatch', g.Operator)
  Group.new('jsonNull', g.Constant)
  Group.new('jsonQuote', g.Delimiter)
  Group.new('jsonString', g.String)
  Group.new('jsonStringSQError', g.Exception)

  -- LUA
  Group.new('luaBraces', g.Structure)
  Group.new('luaBrackets', g.Delimiter)
  Group.new('luaBuiltin', g.Keyword)
  Group.new('luaComma', g.Delimiter)
  Group.new('luaFunction', g.Function)
  Group.new('luaFuncArgName', g.Identifier)
  Group.new('luaFunctionCall', c.blue)
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
  Group.new('luaReturn', c.cyan, nil, s.italic)
  Group.new('luaStatement', c.ice)

  -- Markdown
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
  Group.new('mkdHeading', c.white, nil, s.bold)
  Group.new('mkdItalic', c.white, nil, s.italic)
  Group.new('mkdListItem', g.Special)
  Group.new('mkdRule', g.Underlined)

  -- Rust
  Group.new('rustKeyword', g.Keyword)
  Group.new('rustModPath', g.Include)
  Group.new('rustScopeDecl', g.Delimiter)
  Group.new('rustTrait', g.StorageClass)

  -- VimL
  Group.new('vimNotation', c.orange)
  Group.new('vimBracket', c.orange)
  Group.new('vimMapModKey', c.orange)
  Group.new('vimNotFunc', c.ice)
  Group.new('vimCommand', g.vimNotFunc)
  Group.new('vimFuncSID', c.white)
  Group.new('vimUserFunc', c.cyan)
  Group.new('vimSetSep', c.white)
  Group.new('vimSep', c.white)
  Group.new('vimContinue', c.white)
  Group.new('vimAbb', c.blue)
  Group.new('vimMapLhs', c.yellow)

  -- Java
  Group.new('javaAnnotation', c.blue)
  Group.new('javaDocTags', c.ice)
  Group.new('javaCommentTitle', c.white, nil, s.italic + s.bold)
  Group.new('javaParen', c.white)
  Group.new('javaParen1', c.white)
  Group.new('javaParen2', c.white)
  Group.new('javaParen3', c.white)
  Group.new('javaParen4', c.white)
  Group.new('javaParen5', c.white)
  Group.new('javaOperator', c.cyan)
  Group.new('javaVarArg', c.red)

  -- Xresources
  Group.new('xdefaultsValue', c.white)

  -- SQL
  Group.new('sqlKeyword', c.red)
end

function M:plugins_highlights()
  -- Signify
  Group.new('SignifySignAdd', c.green)
  Group.new('SignifySignChange', c.orange)
  Group.new('SignifySignDelete', c.red)
  Group.new('SignifySignChangeDelete', c.orange_light)

  -- Bufferline.nvim
  Group.new('BufferLineSelected', c.white, c.black, s.bold)
  Group.new('BufferLineTabSelectedSeparator', c.blue)
  Group.new('BufferLineFill', nil, c.grey_darker)
  Group.new('BufferLineBackground', nil, c.grey_darker)
  Group.new('BufferLineInactive', nil, c.grey_darker)

  -- LuaTree
  Group.new('LuaTreeDirty', g.Error)
end

function M:treesitter_highlights()
-- Treesitter
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
  Group.new('TSPunctBracket', c.white)
  Group.new('TSParameter', c.orange)
  Group.new('TSParameterReference', c.orange)
  Group.new('TSRepeat', g.Repeat)
  Group.new('TSOperator', g.Operator)
  Group.new('TSKeyword', g.Keyword)
  Group.new('TSKeywordFunction', g.Function)
  Group.new('TSMethod', g.Function)
  Group.new('TSURI', g.Tag)
  Group.new('TSType', c.ice)
  Group.new('TSTypeBuiltin', c.tan)
  Group.new('TSNamespace', c.orange)
  Group.new('TSInclude', c.cyan)
  Group.new('TSText', c.white)
  Group.new('TSTitle', c.white, nil, s.bold)
  Group.new('TSStrong', c.red, nil, s.bold)
  Group.new('TSEmphasis', c.ice, nil, s.italic)
  Group.new('TSUnderline', c.ice, nil, s.underline)
  Group.new('TSSpecial', c.ice)
  Group.new('TSProperty', c.blue)
  Group.new('TSVariable', g.Identifier)
  Group.new('TSVariableBuiltin', g.Identifier)
end

return M
