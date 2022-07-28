require("bootstrap")
require("impatient").enable_profile()
require("deps")

-- enable filetype.lua
vim.g.do_filetype_lua = 1

-- map leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- order matters
vim.cmd [[
runtime! lua/modules/options.lua
runtime! lua/modules/util.lua
runtime! lua/modules/mappings.lua
]]

local colors = require("vscode.colors")
require('vscode').setup({
  -- Enable italic comment
  italic_comments = true,

  -- Override colors (see ./lua/vscode/colors.lua)
  color_overrides = {
    vscBack = "#0D1017",
    vscFront = "#c7c9d1",
    vscCursorDarkDark = "#171922",
    vscSelection = "#192044",
    vscPopupHighlightBlue = "#192044",
    vscPopupFront = "#3a3e56",
    vscPopupBack = "#262837",
    vscSplitDark = "#3a3e56",
    vscLineNumber = "#252735"
  },

  group_overrides = {
    NonText = { fg = colors.vscLineNumber, bg = "NONE" },
    PMenu = { fg = colors.vscFront, bg = "#262837" },
    PMenuSel = { bg = "#3A3E56" },
    PMenuSbar = { bg = colors.vscPopupBack },
    PMenuSthumb = { bg = "#3A3E56" },
    SignAdd = { fg = "#a7da1e" },
    SignDelete = { fg = "#e61f44" },
    SignChange = { fg = "#f7b83d" }
  }
})

require('feline').setup()

