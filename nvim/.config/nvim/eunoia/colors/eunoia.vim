lua << EOF
-- This file should be edited by the user. Read the instructions of each section and then edit them as desired.

--[[ Highlite, a Neovim colorscheme template.
	* Author:     Iron-E (https://github.com/Iron-E)
	* Repository: https://github.com/nvim-eunoia

	Initially forked from vim-rnb, a Vim colorsheme template:
	* Author:        Romain Lafourcade (https://github.com/romainl)
	* Canonical URL: https://github.com/romainl/vim-rnb
]]

--[[ Introduction
	This template is designed to help Neovim users create their own colorschemes without much effort.

	You will not need any additional tooling to run this file. Just open it in Neovim and follow the instructions.

	The process is divided in five steps:
	1. Rename the template,
	2. Edit your colorscheme's information,
	3. Define your colors,
	4. Define your highlight groups and links, and
	5. Sourcing your colorscheme.
]]

--[[ Step 1: Renaming
	* If this file is distributed with a colorscheme it's probably already named correctly
	  and you can skip this step.
	* If you forked/cloned/copied this repository to create your own colorscheme, you will have to
	  rename this template to match the name of your colorscheme.

	NOTE: Neovim doesn't really care about whitespace in the name of the colorscheme but it does for
	filenames so make sure your filename doesn't have any whitespace character.

	| colorscheme name  | module name | template filename |
	|:-----------------:|:-----------:|:-----------------:|
	| foobar            | foobar      | foobar.lua        |
	| foo-bar           | foo_bar     | foo_bar.lua       |
	| foo bar           | foo_bar     | foo_bar.lua       |
	| foo_bar           | foo_bar     | foo_bar.lua       |

	Rename the following files:
	* `colors/eunoia.vim`
	* `lua/eunoia.lua`

	Where 'eunoia' is the name of your colorscheme.

	TIP: If you are on a Unix-based system (or have WSL on Windows) you can use the setup script at the root of this repo.
	     See the README for more details.
]]


--[[ Step 2: Information
	In this step you will define information that helps Neovim process:

	1. How users access your colorscheme;
	2. How your colorscheme should be rendered.
]]

-- This is the name of your colorscheme which will be used as per |g:colors_name|.
vim.g.colors_name = 'eunoia'

--[[ Step 3: Colors
	Next you will define all of the colors that you will use for the color scheme.

	Each one should be made up of three parts:

```lua
	<color name> = { -- Give each color a distinctive name.
		'#<hex color code>', -- Hexadecimal color used in GVim/MacVim or 'NONE'.
		<16-bit color code>, -- Integer 0–255 used by terminals supporting 256 colors or 'NONE'.
		'<ANSI color name>'  -- color name used by less capable color terminals, can be 'darkred',
		                       'red', 'darkgreen', 'green', 'darkyellow', 'yellow', 'darkblue',
		                       'blue', 'darkmagenta', 'magenta', 'black', 'darkgrey', 'grey',
		                       'white', or 'NONE'
	}
```

	If your colors are defined correctly, the resulting colorscheme is guaranteed
	to work in GVim (Windows/Linux), MacVim (MacOS), and any properly set up terminal emulator.

	NOTE: |Replace-mode| will probably be useful here.
]]

local black       = {'#151326', 0,   'black'}
local gray        = {'#2C2941', 244, 'gray'}
local gray_dark   = {'#211D35', 236, 'darkgrey'}
local gray_darker = {'#1D192E', 244, 'gray'}
local gray_light  = {'#4B5573', 251, 'gray'}
local white       = {'#DEDBD6', 15,  'white'}

local tan = {'#FFB55E', 180, 'darkyellow'}

local red       = {'#FF496F', 196, 'red'}
local red_dark  = {'#CC173C', 124, 'darkred'}
local red_light = {'#FF4356', 203, 'red'}

local orange       = {'#FE5B45', 208, 'darkyellow'}
local orange_light = {'#FC9349', 214, 'yellow'}

local yellow = {'#FFE064', 220, 'yellow'}

local green_dark  = {'#2CBD80', 83, 'darkgreen'}
local green       = {'#44D695', 72, 'green'}
local green_light = {'#51E78C', 72, 'green'}

local blue     = {'#6391F4', 63, 'darkblue'}
local cyan     = {'#58CDFF', 87, 'cyan'}
local ice      = {'#6370F4', 63, 'cyan'}
local teal     = {'#4EC2D9', 38, 'cyan'}
local turqoise = {'#2bff99', 33, 'blue'}

local magenta      = {'#E36DD4', 126, 'magenta'}
local magenta_dark = {'#BE5DC9', 126, 'darkmagenta'}
local pink         = {'#DA6DE3', 162, 'magenta'}
local pink_light   = {'#FFA6FF', 38,  'white'}
local purple       = {'#BA6DFF', 129, 'magenta'}
local purple_light = {'#C874FF', 63,  'magenta'}

--[[ Step 4: highlights
	You can define highlight groups like this:

```lua
	<highlight group name> = {
		bg=<color>, -- The color for the background, `NONE`, `FG` or `BG`
		fg=<color>, -- The color for the foreground, `NONE`, `FG` or `BG`
		blend=<integer> -- The |highlight-blend| value, if one is desired.
		-- Style can be 'bold', 'italic', and more. See |attr-list| for more information.
		-- It can also have a color, and/or multiple <cterm>s.
		style=<cterm>|{<cterm> [, <cterm>] [color=<color>]})
	}
```

	You can also link one highlight group to another:

```lua
	<highlight group name> = '<highlight group name>'
```
	____________________________________________________________________________

	Here is an example to define `SpellBad` and then link some new group
	`SpellWorse` to it:

```lua
	SpellBad = { -- ← name of the highlight group
		bg=NONE, -- background color
		fg=red, -- foureground color
		style={ -- the style
			'undercurl', -- undercurl (squiggly line)
			color=red -- the color of the undercurl
		}
	},
	SpellWorse = 'SpellBad'
```

	If you weren't satisfied with undercurl, and also wanted another effect, you can
	add another one below 'undercurl' and it will be applied as well:

```lua
	SpellBad = { -- ← name of the highlight group
		bg=NONE, -- background color
		fg=red, -- foureground color
		style={ -- the style
			'undercurl', -- undercurl (squiggly line)
			'standout'
			color=red -- the color of the undercurl
		}
	}
```
	____________________________________________________________________________

	If you want to create a colorscheme that is responsive to the user's
	'background' setting, you can specify special `light` and `dark` keys to
	define how each group should be highlighted in each case.

```lua
	SpellBad = {
		bg=NONE,
		dark={fg=white},
		light={fg=black},
		style={'undercurl', color=red}
	}
```

	Whenever the user changes their 'background' setting, the settings inside of
	whichever key is relevant will be loaded.
	____________________________________________________________________________

	You can add any custom highlight group to the standard list below but you
	shouldn't remove any if you want a working colorscheme. Most of them are
	described under |highlight-default|, some from |group-name|, and others from
	common syntax groups.  Both help sections are good reads.

	NOTE: |Replace-mode| will probably be useful here.

	NOTE: /As long as you do not remove any highlight groups or colors/, you can
	      safely ignore any highlight groups that are `link`ed to others.

	      For example, programming languages almost exclusively link to the 1st
	      and 2nd sections, so as long as you define everything there you will
	      automatically be defining the rest of the highlights, which is one of
	      the benefits of using this template.
]]

--[[ DO NOT EDIT `BG`, `FG`, or `NONE`.
	Feel free to uncomment `BG` and `NONE`. They are not used by default so they are commented out.
]]
-- local BG   = 'bg'
local FG   = 'fg'
-- local NONE = 'NONE'

--[[ These are the ones you should edit. ]]
-- This is the only highlight that must be defined separately.
local highlight_group_normal = {bg=black, fg=white}

-- This is where the rest of your highlights should go.
local highlight_groups = {
	--[[ 4.1. Text Analysis ]]
	Comment     = {fg=gray_light, style='italic'},
	NonText     = {fg=gray_darker},
	EndOfBuffer = 'NonText',
	Whitespace  = 'NonText',

	--[[ 4.1.1. Literals]]
	Constant  = {fg=orange_light},
	String    = {fg=green},
	Character = {fg=red_light},
	Number    = {fg=pink_light},
	Boolean   = {fg=yellow},
	Float     = 'Number',

	--[[ 4.1.2. Identifiers]]
	Identifier = {fg=white},
	Function   = {fg=teal},

	--[[ 4.1.3. Syntax]]
	Statement   = {fg=red},
	Conditional = {fg=ice,      style='italic'},
	Repeat      = {fg=turqoise },
	Label       = {fg=pink,     style='italic'},
	Operator    = {fg=orange},
	Keyword     = {fg=red},
	Exception   = {fg=red_light, style='bold'},
	Noise       = 'Delimiter',

	--[[ 4.1.4. Metatextual Information]]
	PreProc   = {fg=tan},
	Include   = {fg=cyan,        style='nocombine'},
	Define    = {fg=blue,        style='nocombine'},
	Macro     = {fg=blue,        style='italic'},
	PreCondit = {fg=tan,         style='italic'},

	--[[ 4.1.5. Semantics]]
	Type         = {fg=blue},
	StorageClass = {fg=orange_light },
	Structure    = {fg=cyan},
	Typedef      = {fg=cyan,         style='italic'},

	--[[ 4.1.6. Edge Cases]]
	Special        = {fg=ice},
	SpecialChar    = {fg=red_light, style='italic'},
	SpecialKey     = 'Character',
	Tag            = 'Underlined',
	Delimiter      = {fg=white},
	SpecialComment = {fg=red, style={'bold', 'nocombine'}},
	Debug          = 'WarningMsg',

	--[[ 4.1.7. Help Syntax]]
	Underlined        = {fg=cyan, style='underline'},
	Ignore            = {fg=gray},
	Error             = {bg=NONE,     fg=dark_red},
	Todo              = {fg=yellow,   style={'bold', 'underline'}},
	helpHyperTextJump = 'Underlined',
	helpSpecial       = 'Function',
	Hint              = {bg=NONE,     fg=magenta, style='bold'},
	Info              = {bg=NONE,     fg=ice,     style='bold'},
	Warning           = {bg=NONE,     fg=orange,  style='bold'},

	--[[ 4.2... Editor UI  ]]
	--[[ 4.2.1. Status Line]]
	StatusLine       = {bg=gray_darker, fg=green_light},
	StatusLineNC     = {bg=gray_darker, fg=gray},
	StatusLineTerm   = 'StatusLine',
	StatusLineTermNC = 'StatusLineNC',

	--[[ 4.2.2. Separators]]
	VertSplit   = {fg=gray, bg=gray},
	TabLine     = {bg=black, fg=FG},
	TabLineFill = {fg=FG},
	TabLineSel  = {bg=gray_darker, fg=FG, style='inverse'},
	Title       = {style='bold'},

	--[[ 4.2.3. Conditional Line Highlighting]]
	--Conceal={}
	CursorLine      = {bg=gray_dark},
	CursorLineNr    = {bg=gray_dark, fg=blue, style="bold"},
	debugBreakpoint = 'ErrorMsg',
	debugPC         = 'ColorColumn',
	LineNr          = 'Comment',
	QuickFixLine    = {bg=gray_darker},
	Visual          = {bg=gray_dark},
	VisualNOS       = {bg=gray_darker},

	--[[ 4.2.4. Popup Menu]]
	Pmenu      = {bg=gray_dark, fg=FG},
	PmenuSbar  = {bg=black},
	PmenuSel   = {bg=blue, fg=black},
	PmenuThumb = {bg=gray},
	WildMenu   = {},

	--[[ 4.2.5. Folds]]
	FoldColumn = {bg=gray_dark,             style='bold'},
	Folded     = {bg=gray_dark,  fg=black,  style='italic'},

	--[[ 4.2.6. Diffs]]
	DiffAdd    = {fg=green_dark, style='inverse'},
	DiffChange = {fg=yellow,     style='inverse'},
	DiffDelete = {fg=red,        style='inverse'},
	DiffText   = {style='inverse'},

	--[[ 4.2.7. Searching]]
	IncSearch  = {style='inverse'},
	Search     = {style={'underline', color=white}},
	MatchParen = {fg=green, style={'bold', 'underline'}},

	--[[ 4.2.8. Spelling]]
	SpellBad   = {style={'undercurl', color=red}},
	SpellCap   = {style={'undercurl', color=yellow}},
	SpellLocal = {style={'undercurl', color=green}},
	SpellRare  = {style={'undercurl', color=orange}},

	--[[ 4.2.8. LuaTree]]
	LuaTreeDirty  = 'Error',

	--[[ 4.2.9. Conditional Column Highlighting]]
	ColorColumn = {bg=gray_dark},
	SignColumn  = {},

	--[[ 4.2.10. Messages]]
	ErrorMsg   = {fg=red,          style='bold'},
	HintMsg    = {fg=magenta,      style='bold'},
	InfoMsg    = {fg=cyan,         style='bold'},
	ModeMsg    = {fg=yellow},
	WarningMsg = {fg=orange,       style='bold'},
	Question   = {fg=orange_light, style='underline'},

	--[[ 4.2.11. LSP ]]
	LspDiagnosticsError = 'Error',
	LspDiagnosticsErrorFloating = 'ErrorMsg',
	LspDiagnosticsErrorSign = 'ErrorMsg',

	LspDiagnosticsWarning = 'Warning',
	LspDiagnosticsWarningFloating = 'WarningMsg',
	LspDiagnosticsWarningSign = 'WarningMsg',

	LspDiagnosticsHint = 'Hint',
	LspDiagnosticsHintFloating = 'HintMsg',
	LspDiagnosticsHintSign = 'HintMsg',

	LspDiagnosticsInformation = 'Info',
	LspDiagnosticsInformationFloating = 'InfoMsg',
	LspDiagnosticsInformationSign = 'InfoMsg',

	LspDiagnosticsUnderline = {style={'undercurl', color=white}},
	LspDiagnosticsUnderlineError = 'CocErrorHighlight',
	LspDiagnosticsUnderlineHint  = 'CocHintHighlight',
	LspDiagnosticsUnderlineInfo  = 'CocInfoHighlight',
	LspDiagnosticsUnderlineWarning = 'CocWarningHighlight',

	--[[ 4.2.12. Cursor ]]
	Cursor   = {style='inverse'},
	CursorIM = 'Cursor',
	CursorColumn = {bg=gray_dark},

	--[[ 4.2.13. Misc ]]
	Directory = {fg=ice, style='bold'},

	--[[ 4.3. Programming Languages
		Everything in this section is OPTIONAL. Feel free to remove everything
		here if you don't want to define it, or add more if there's something
		missing.
	]]
	--[[ 4.3.1. C ]]
	cConstant    = 'Constant',
	cCustomClass = 'Type',

	--[[ 4.3.2. C++ ]]
	cppSTLexception = 'Exception',
	cppSTLnamespace = 'String',

	--[[ 4.3.3 C# ]]
	csBraces     = 'Delimiter',
	csClass      = 'Structure',
	csClassType  = 'Type',
	csContextualStatement = 'Conditional',
	csEndColon   = 'Delimiter',
	csGeneric    = 'Typedef',
	csInterpolation = 'Include',
	csInterpolationDelimiter = 'SpecialChar',
	csLogicSymbols  = 'Operator',
	csModifier   = 'Keyword',
	csNew        = 'Operator',
	csNewType    = 'Type',
	csParens     = 'Delimiter',
	csPreCondit  = 'PreProc',
	csRepeat     = 'Repeat',
	csStorage    = 'StorageClass',
	csUnspecifiedStatement = 'Statement',
	csXmlTag     = 'Define',
	csXmlTagName = 'Define',

	--[[ 4.3.4. CSS ]]
	cssBraces     = 'Delimiter',
	cssProp       = 'Keyword',
	cssSelectorOp = 'Operator',
	cssTagName    = 'Type',
	cssTagName    = 'htmlTagName',
	cssClassName  = { fg = tan },
	scssAmpersand = 'Special',
	scssAttribute = 'Label',
	scssBoolean   = 'Boolean',
	scssDefault   = 'Keyword',
	scssElse      = 'PreCondit',
	scssIf        = 'PreCondit',
	scssInclude   = 'Include',
	scssSelectorChar = 'Operator',
	scssSelectorName = 'Identifier',
	scssVariable  = 'Define',
	scssVariableAssignment = 'Operator',

	--[[ 4.3.5. Dart ]]
	dartLibrary = 'Statement',

	--[[ 4.3.6. dot ]]
	dotKeyChar = 'Character',
	dotType    = 'Type',

	--[[ 4.3.7. Go ]]
	goBlock                 = 'Delimiter',
	goBoolean               = 'Boolean',
	goBuiltins              = 'Operator',
	goField                 = 'Identifier',
	goFloat                 = 'Float',
	goFormatSpecifier       = 'Character',
	goFunction              = 'Function',
	goFunctionCall          = 'goFunction',
	goFunctionReturn        = {},
	goMethodCall            = 'goFunctionCall',
	goParamType             = 'goReceiverType',
	goPointerOperator       = 'SpecialChar',
	goPredefinedIdentifiers = 'Constant',
	goReceiver              = 'goBlock',
	goReceiverType          = 'goTypeName',
	goSimpleParams          = 'goBlock',
	goType                  = 'Type',
	goTypeConstructor       = 'goFunction',
	goTypeName              = 'Type',
	goVarAssign             = 'Identifier',
	goVarDefs               = 'goVarAssign',

	--[[ 4.3.8. HTML ]]
	htmlArg     = 'Label',
	htmlBold    = {fg=gray_light, style='bold'},
	htmlTitle   = 'htmlBold',
	htmlEndTag  = 'htmlTag',
	htmlH1      = 'markdownH1',
	htmlH2      = 'markdownH2',
	htmlH3      = 'markdownH3',
	htmlH4      = 'markdownH4',
	htmlH5      = 'markdownH5',
	htmlH6      = 'markdownH6',
	htmlItalic  = {style='italic'},
	htmlSpecialTagName = 'htmlTagName',
	htmlTag     = 'Special',
	htmlTagN    = 'Typedef',
	htmlTagName = { fg = red },
	htmlAttr = 'Label',

	--[[ 4.3.9. Java ]]
	javaClassDecl = 'Structure',

	--[[ 4.3.10. JavaScript ]]
	jsFuncBlock   = 'Function',
	jsObjectKey   = 'Type',
	jsReturn      = 'Keyword',
	jsVariableDef = 'Identifier',
	jsModuleKeyword = { fg = red },

	--[[ 4.3.11. JSON ]]
	jsonBraces = 'luaBraces',
	jsonKeywordMatch = 'Operator',
	jsonNull   = 'Constant',
	jsonQuote  = 'Delimiter',
	jsonString = 'String',
	jsonStringSQError = 'Exception',

	--[[ 4.3.12. Lua ]]
	luaBraces       = 'Structure',
	luaBrackets     = 'Delimiter',
	luaBuiltin      = 'Keyword',
	luaComma        = 'Delimiter',
	luaFuncArgName  = 'Identifier',
	luaFuncCall     = 'Function',
	luaFuncId       = 'luaNoise',
	luaFuncKeyword  = 'Type',
	luaFuncName     = 'Function',
	luaFuncParens   = 'Delimiter',
	luaFuncTable    = 'Structure',
	luaLocal        = 'Type',
	luaNoise        = 'Operator',
	luaParens       = 'Delimiter',
	luaSpecialTable = 'StorageClass',
	luaSpecialValue = 'Function',
	luaIdentifier   = 'Identifier',

	--[[ 4.3.12. Make ]]
	makeCommands   = 'Statment',
	makeSpecTarget = 'Type',

	--[[ 4.3.13. Markdown ]]
	markdownH1          = {fg=red, style='bold'},
	markdownH2          = {fg=orange, style='bold'},
	markdownH3          = {fg=yellow, style='bold'},
	markdownH4          = {fg=green_dark, style='bold'},
	markdownH5          = {fg=cyan, style='bold'},
	markdownH6          = {fg=purple_light, style='bold'},
	mkdBold             = 'SpecialComment',
	mkdCode             = 'Keyword',
	mkdCodeDelimiter    = 'mkdBold',
	mkdCodeStart        = 'mkdCodeDelimiter',
	mkdCodeEnd          = 'mkdCodeStart',
	mkdHeading          = 'Delimiter',
	mkdItalic           = 'mkdBold',
	mkdListItem         = 'Special',
	mkdRule             = 'Underlined',
	texMathMatcher      = 'Number',
	texMathZoneX        = 'Number',
	texMathZoneY        = 'Number',

	--[[ 4.3.20. Python ]]
	pythonBrackets        = 'Delimiter',
	pythonBuiltinFunc     = 'Operator',
	pythonBuiltinObj      = 'Type',
	pythonBuiltinType     = 'Type',
	pythonClass           = 'Structure',
	pythonClassParameters = 'pythonParameters',
	pythonDecorator       = 'PreProc',
	pythonDottedName      = 'Identifier',
	pythonError           = 'Error',
	pythonException       = 'Exception',
	pythonInclude         = 'Include',
	pythonIndentError     = 'pythonError',
	pythonLambdaExpr      = 'pythonOperator',
	pythonOperator        = 'Operator',
	pythonParam           = 'Identifier',
	pythonParameters      = 'Delimiter',
	pythonSelf            = 'Statement',
	pythonSpaceError      = 'pythonError',
	pythonStatement       = 'Statement',

	--[[ 4.3.21. Ruby ]]
	rubyClass                  = 'Structure',
	rubyDefine                 = 'Define',
	rubyInterpolationDelimiter = 'Delimiter',

	--[[ 4.3.22. Rust ]]
	rustKeyword   = 'Keyword',
	rustModPath   = 'Include',
	rustScopeDecl = 'Delimiter',
	rustTrait     = 'StorageClass',

	--[[ 4.3.23. Scala ]]
	scalaKeyword        = 'Keyword',
	scalaNameDefinition = 'Identifier',

	--[[ 4.3.24. shell ]]
	shDerefSimple = 'SpecialChar',
	shFunctionKey = 'Function',
	shLoop    = 'Repeat',
	shParen   = 'Delimiter',
	shQuote   = 'Delimiter',
	shSet     = 'Statement',
	shTestOpr = 'Debug',

	--[[ 4.3.25. Solidity ]]
	solBuiltinType  = 'Type',
	solContract     = 'Typedef',
	solContractName = 'Function',

	--[[ 4.3.26. TOML ]]
	tomlComment = 'Comment',
	tomlKey     = 'Label',
	tomlTable   = 'StorageClass',

	--[[ 4.3.27. VimScript ]]
	helpSpecial    = 'Special',
	vimFgBgAttrib  = 'Constant',
	vimHiCterm     = 'Label',
	vimHiCtermFgBg = 'vimHiCterm',
	vimHiGroup     = 'Typedef',
	vimHiGui       = 'vimHiCterm',
	vimHiGuiFgBg   = 'vimHiGui',
	vimHiKeyList   = 'Operator',
	vimOption      = 'Define',
	vimSetEqual    = 'Operator',
	vimContinue    = 'Comment',

	--[[ 4.3.28. XML ]]
	xmlAttrib  = 'htmlArg',
	xmlEndTag  = 'xmlTag',
	xmlEqual   = 'Operator',
	xmlTag     = 'htmlTag',
	xmlTagName = 'htmlTagName',

	--[[ 4.3.29. SQL ]]
	sqlKeyword   = 'Keyword',
	sqlParen     = 'Delimiter',
	sqlSpecial   = 'Constant',
	sqlStatement = 'Statement',
	sqlParenFunc = 'Function',

	--[[ 4.3.30. dos INI ]]
	dosiniHeader = 'Title',

	--[[ 4.3.31. Crontab ]]
	crontabDay  = 'StorageClass',
	crontabDow  = 'String',
	crontabHr   = 'Number',
	crontabMin  = 'Float',
	crontabMnth = 'Structure',

	--[[ 4.3.33. Svelte ]]
  svelteComponentName = { fg = tan },

	--[[ 4.4. Plugins
		Everything in this section is OPTIONAL. Feel free to remove everything
		here if you don't want to define it, or add more if there's something
		missing.
	]]
	--[[ 4.4.1. ALE ]]
	ALEErrorSign   = 'ErrorMsg',
	ALEWarningSign = 'WarningMsg',

	--[[ 4.4.2. coc.nvim ]]
	CocErrorHighlight   = {style={'undercurl', color='red'}},
	CocHintHighlight    = {style={'undercurl', color='magenta'}},
	CocInfoHighlight    = {style={'undercurl', color='pink_light'}},
	CocWarningHighlight = {style={'undercurl', color='orange'}},
	CocErrorSign   = 'ALEErrorSign',
	CocHintSign    = 'HintMsg',
	CocInfoSign    = 'InfoMsg',
	CocWarningSign = 'ALEWarningSign',

	--[[ 4.4.2. vim-jumpmotion / vim-easymotion ]]
	EasyMotion = 'IncSearch',
	JumpMotion = 'EasyMotion',

	--[[ 4.4.4. vim-gitgutter / vim-signify ]]
	GitGutterAdd          = {fg=green},
	GitGutterChange       = {fg=orange},
	GitGutterDelete       = {fg=red},
	GitGutterChangeDelete = {fg=yellow},

	SignifySignAdd    = 'GitGutterAdd',
	SignifySignChange = 'GitGutterChange',
	SignifySignDelete = 'GitGutterDelete',
	SignifySignChangeDelete = 'GitGutterChangeDelete',

	--[[ 4.4.5. vim-indent-guides ]]
	IndentGuidesOdd  = 'Comment',
	IndentGuidesEven = 'Comment',

	--[[ 4.4.8. nvim-treesitter ]]
	TSBoolean = 'Boolean',
	TSConstBuiltin = 'Constant',
	TSConstMacro   = 'Constant',
	TSConstructor  = 'Function',
	TSFuncBuiltin  = 'Function',
	TSString = 'String',
	TSCharacter = 'String',
	TSConditional = 'String',
	TSError = 'Error',
	TSNumber = 'Number',
	TSFloat = 'Float',
	TSLabel = 'Boolean',
	TSFunction = 'Function',
	TSStringEscape = 'Character',
	TSStringRegex  = 'SpecialChar',
	TSPunctDelimiter  = 'Delimiter',
	TSPunctBracket = { fg = white },
	TSParameter = { fg = orange },
	TSParameterReference = { fg = orange },
	TSRepeat = 'Repeat',
	TSOperator = 'Operator',
	TSKeyword = 'Keyword',
	TSKeywordFunction = 'Function',
	TSMethod = 'Function',
	TSURI = 'Tag',
	TSType = { fg = tan },
	TSTypeBuiltin = { fg = tan },
	TSNamespace = { fg = orange },
	TSInclude = { fg = cyan },
	TSText = { fg = white },
	TSTitle = { fg = red, style = 'bold' },
	TSStrong = { fg = red, style = 'bold' },
	TSEmphasis = { fg = ice, style = 'italic' },
	TSUnderline = { fg = ice, style = 'underline' },
	TSSpecial = { fg = ice },
	TSVariable = 'Identifier',
	TSVariableBuiltin = 'Identifier',
}

--[[ Step 5: Terminal Colors
	 | Index  | Name          |
	 |:------:|:-------------:|
	 | 1      | black         |
	 | 2      | darkred       |
	 | 3      | darkgreen     |
	 | 4      | darkyellow    |
	 | 5      | darkblue      |
	 | 6      | darkmagenta   |
	 | 7      | darkcyan      |
	 | 8      | gray          |
	 | 9      | darkgray      |
	 | 10     | red           |
	 | 11     | green         |
	 | 12     | yellow        |
	 | 13     | blue          |
	 | 14     | magenta       |
	 | 15     | cyan          |
	 | 16     | white         |
]]

local terminal_ansi_colors = {
	[1]  = black,
	[2]  = red_dark,
	[3]  = green_dark,
	[4]  = orange,
	[5]  = blue,
	[6]  = magenta_dark,
	[7]  = teal,
	[8]  = gray,
	[9]  = gray_dark,
	[10] = red,
	[11] = green,
	[12] = yellow,
	[13] = turqoise,
	[14] = purple,
	[15] = cyan,
	[16] = gray_light
}

require('eunoia')(
	highlight_group_normal,
	highlight_groups,
	terminal_ansi_colors
)

-- Thanks to Romain Lafourcade (https://github.com/romainl) for the original template (romainl/vim-rnb).
-- vim: ft=lua
EOF
