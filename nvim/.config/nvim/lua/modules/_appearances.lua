local set_hl = require("modules._util").set_hl

ColorUtil = {}

ColorUtil.override_gruvbox = function()
  local highlights = {
    -- normal stuff
    -- { "Normal",      { bg  = "NONE"    }},
    { "Normal",      { bg  = "#1d2021"    }},
    { "Comment",     { gui = "italic"  }},
    { "SignColumn",  { bg  = "NONE"    }},
    { "ColorColumn", { bg  = "#3C3836" }},
    { "String",      { gui = "NONE"    }},
    { "Special",     { gui = "NONE"    }},
    { "Folded",      { gui = "NONE"    }},
    { "EndOfBuffer", { bg  = "NONE",fg = "#282828" }},
    { "OnYank",      { link  = "Visual" }},

    -- tabline stuff
    { "Tabline",            { bg = "NONE"  }},
    { "TablineSuccess",     { bg = "NONE", fg = "#b8bb26", gui = "bold" }},
    { "TablineError",       { bg = "NONE", fg = "#fb4934"  }},
    { "TablineWarning",     { bg = "NONE", fg = "#d79921"  }},
    { "TablineInformation", { bg = "NONE", fg = "#458588"  }},
    { "TablineHint",        { bg = "NONE", fg = "#689D6A"  }},

    -- vim-illuminate
    { "illuminatedWord", { gui = "underline" } },

    -- git stuff
    { "SignAdd",    { fg = "#458588", bg = "NONE" }},
    { "SignChange", { fg = "#D79921", bg = "NONE" }},
    { "SignDelete", { fg = "#fb4934", bg = "NONE" }},

    -- lsp saga stuff
    { "TargetWord",             { fg = "#d79921", bg  = "NONE",    gui = "bold" }},
    { "LspDiagErrorBorder",     { fg = "#fb4934", gui = "bold" }},
    { "LspDiagWarnBorder",      { fg = "#d79921", gui = "bold" }},
    { "LspDiagInfoBorder",      { fg = "#458588", gui = "bold" }},
    { "LspDiagHintBorder",      { fg = "#458588", gui = "bold" }},

    -- octo.nvim stuff
    { "OctoNvimIssueOpen",         { fg = "#b8bb26" }},
    { "OctoNvimIssueClosed",       { fg = "#fb4934" }},
    { "OctoNvimDirty",             { fg = "#fb4934" }},
    { "OctoNvimPullAdditions",     { fg = "#b8bb26" }},
    { "OctoNvimPullDeletions",     { fg = "#fb4934" }},
    { "OctoNvimPullModifications", { fg = "#d79921" }},

    -- misc
    { "jsonNoQuotesError",     { fg  = "#fb4934" }},
    { "jsonMissingCommaError", { fg  = "#fb4934" }},
    { "mkdLineBreak",          { bg  = "NONE"    }},
    { "htmlLink",              { gui = "NONE",    fg  = "#ebdbb2"   }},
    { "IncSearch",             { bg  = "#282828", fg  = "#928374"   }},
    { "mkdLink",               { fg  = "#458588", gui = "underline" }},
    { "markdownCode",          { bg  = "NONE",    fg  = "#fe8019"   }},

    -- statusline colours
    { "StatusLine",   { bg = "#3C3836", fg = "#EBDBB2", gui = "NONE" }},
    { "StatusLineNC", { bg = "#3C3836", fg = "#928374", gui = "NONE" }},
    { "Mode",         { bg = "#928374", fg = "#1D2021", gui = "bold" }},
    { "LineCol",      { bg = "#504945", fg = "#ebdbb2", gui = "bold" }},
    { "LineColAlt",   { bg = "#3C3836", fg = "#ebdbb2" }},
    { "Git",          { bg = "#928374", fg = "#1D2021", gui = "bold" }},
    { "Filetype",     { bg = "#504945", fg = "#EBDBB2" }},
    { "Filename",     { bg = "#504945", fg = "#EBDBB2" }},
    { "ModeAlt",      { bg = "#504945", fg = "#928374" }},
    { "GitAlt",       { bg = "#3C3836", fg = "#504945" }},
    { "FiletypeAlt",  { bg = "#3C3836", fg = "#504945" }},

    -- nvimtree
    { "NvimTreeFolderIcon",   { fg = "#d79921" }},
    { "NvimTreeIndentMarker", { fg = "#928374" }},

    -- telescope
    { "TelescopeSelection",    { bg = "NONE", fg = "#d79921", gui = "bold" }},
    { "TelescopeMatching",     { bg = "NONE", fg = "#fb4934", gui = "bold" }},
    { "TelescopeBorder",       { bg = "NONE", fg = "#928374", gui = "bold" }},

    -- diagnostic stuff
    { "LspDiagnosticsDefaultError",         { bg  = "NONE", fg = "#fb4934" }},
    { "LspDiagnosticsDefaultWarning",       { bg  = "NONE", fg = "#d79921" }},
    { "LspDiagnosticsDefaultInformation",   { bg  = "NONE", fg = "#458588" }},
    { "LspDiagnosticsDefaultHint",          { bg  = "NONE", fg = "#689D6A" }},
    { "LspDiagnosticsUnderlineError",       { gui = "underline" }},
    { "LspDiagnosticsUnderlineWarning",     { gui = "underline" }},
    { "LspDiagnosticsUnderlineInformation", { gui = "underline" }},
    { "LspDiagnosticsUnderlineHint",        { gui = "underline" }},

    -- ts override
    { "Bordaa",           { bg = "NONE", fg = "#504945" }},
    { "FloatBorder",      { bg = "#504945", fg = "#A69481" }},
    -- { "TSKeywordOperator", { bg = "NONE", fg = "#fb4934" }},
    -- { "TSOperator",        { bg = "NONE", fg = "#fe8019" }},


    -- temporary html stuff
    { "htmlTag",          { link = "TSAttribute" } },
    { "htmlArg",          { link = "TSProperty" } },
    { "htmlEvent",        { link = "TSProperty" } },
  }

  for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end
end

ColorUtil.override_onedark = function()
  local highlights = {
    -- normal stuff
    { "Normal",      { bg  = "NONE" }},
    { "Comment",     { gui = "italic"  }},
    { "SignColumn",  { bg  = "NONE"    }},
    { "IncSearch",   { bg  = "#61afef", fg = "#14151a" }},
    { "OnYank",      { bg  = "#3f4450" }},
    { "Visual",      { bg  = "#3f4450", fg = "NONE" }},
    { "VertSplit",   { fg  = "#14151a", bg = "NONE" }},
    { "String",      { gui = "NONE"    }},
    { "Special",     { gui = "NONE"    }},
    { "Folded",      { gui = "NONE"    }},
    { "EndOfBuffer", { bg  = "NONE"    }},

    -- git stuff
    { "SignAdd",    { fg = "#61afef", bg = "NONE" }},
    { "SignChange", { fg = "#e5c07b", bg = "NONE" }},
    { "SignDelete", { fg = "#e95678", bg = "NONE" }},

    -- tabline stuff
    { "Tabline",            { bg = "NONE"  }},
    { "TablineSuccess",     { bg = "NONE", fg = "#abcf84", gui = "bold" }},
    { "TablineError",       { bg = "NONE", fg = "#e95678"  }},
    { "TablineWarning",     { bg = "NONE", fg = "#e5c07b"  }},
    { "TablineInformation", { bg = "NONE", fg = "#61afef"  }},
    { "TablineHint",        { bg = "NONE", fg = "#56b6c2"  }},

    -- diagnostic stuff
    { "LspDiagnosticsDefaultError",         { bg  = "NONE", fg = "#e95678" }},
    { "LspDiagnosticsDefaultWarning",       { bg  = "NONE", fg = "#e5c07b" }},
    { "LspDiagnosticsDefaultInformation",   { bg  = "NONE", fg = "#61afef" }},
    { "LspDiagnosticsDefaultHint",          { bg  = "NONE", fg = "#abcf84" }},
    { "LspDiagnosticsUnderlineError",       { fg = "NONE", gui = "underline" }},
    { "LspDiagnosticsUnderlineWarning",     { fg = "NONE", gui = "underline" }},
    { "LspDiagnosticsUnderlineInformation", { fg = "NONE", gui = "underline" }},
    { "LspDiagnosticsUnderlineHint",        { fg = "NONE", gui = "underline" }},

    -- telescope
    { "TelescopeSelection",       { bg = "NONE", fg = "#61afef", gui = "bold" }},
    { "TelescopeMatching",        { bg = "NONE", fg = "#e95678", gui = "bold" }},
    { "TelescopeBorder",          { bg = "NONE", fg = "#3f4450", gui = "bold" }},
    { "TelescopePromptBorder",    { bg = "NONE", fg = "#61afef", gui = "bold" }},

    -- statusline colours
    { "StatusLine",   { bg = "#14151a", fg = "#bbc2cf", gui = "NONE" }},
    { "StatusLineNC", { bg = "#14151a", fg = "#5B6268", gui = "NONE" }},
    { "Mode",         { bg = "#5B6268", fg = "#14151a", gui = "bold" }},
    { "LineCol",      { bg = "#3f4450", fg = "#bbc2cf", gui = "bold" }},
    { "LineColAlt",   { bg = "#14151a", fg = "#bbc2cf" }},
    { "Git",          { bg = "#5B6268", fg = "#14151a", gui = "bold" }},
    { "Filetype",     { bg = "#3f4450", fg = "#bbc2cf" }},
    { "Filename",     { bg = "#3f4450", fg = "#bbc2cf" }},
    { "ModeAlt",      { bg = "#3f4450", fg = "#5B6268" }},
    { "GitAlt",       { bg = "#14151a", fg = "#3f4450" }},
    { "FiletypeAlt",  { bg = "#14151a", fg = "#3f4450" }},

    { "BiscuitColor",    { fg = "#5B6268", bg = "NONE", gui = "bold" }},

    { "TSVariable",           { fg = "#ABB2BF", bg = "NONE" }},
    { "TSVariableBuiltin",    { fg = "#E5C07B", bg = "NONE" }},
    { "TSPunctBracket",       { fg = "#ABB2BF", bg = "NONE" }},
    { "TSPunctDelimiter",     { fg = "#ABB2BF", bg = "NONE" }},
    { "TSConstructor",        { fg = "#e95678", bg = "NONE" }},
    { "TSTagDelimiter",       { fg = "#61afef", bg = "NONE" }},

    { "Pmenu",       { bg = "#333740", fg = "NONE" }},
    { "Bordaa",      { bg = "NONE", fg = "#333740" }},
  }

  for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end
end

-- italicize comments
set_hl("Comment", { gui = "italic" })

-- automatically override colourscheme
vim.api.nvim_exec([[
  augroup NewColor
  au!
  au ColorScheme gruvbox8 call v:lua.ColorUtil.override_gruvbox()
  au ColorScheme onedark call v:lua.ColorUtil.override_onedark()
  augroup END
]], false)

-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false
vim.cmd [[colorscheme gruvbox8]]

-- needs to be loaded after setting colourscheme
vim.cmd [[packadd nvim-web-devicons]]
require("nvim-web-devicons").setup {
  override = {
    svg = {
      icon  = "",
      color = "#ebdbb2",
      name  = "Svg",
    },
  },
  default = true,
}
