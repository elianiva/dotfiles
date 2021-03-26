local set_hl = require("modules._util").set_hl

ColorUtil = {}

ColorUtil.override_gruvbox = function()
  local highlights = {
    -- normal stuff
    { "Normal",      { bg  = "NONE"    }},
    { "Comment",     { gui = "italic"  }},
    { "SignColumn",  { bg  = "NONE"    }},
    { "ColorColumn", { bg  = "#3C3836" }},
    { "IncSearch",   { bg  = "#928374" }},
    { "String",      { gui = "NONE"    }},
    { "Special",     { gui = "NONE"    }},
    { "Folded",      { gui = "NONE"    }},
    { "EndOfBuffer", { bg  = "NONE",fg = "#282828" }},

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
    { "LspSagaFinderSelection", { fg = "#d79921", bg  = "#3C3836", gui = "bold" }},
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
    { "StrikeThrough",         { gui = "strikethrough" }},

    -- statusline colours
    { "StatusLine",   { bg = "#EBDBB2", fg = "#3C3836" }},
    { "StatusLineNC", { bg = "#928374", fg = "#3C3836" }},
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
    { "TelescopeSelection", { bg = "NONE", fg = "#d79921", gui = "bold" }},
    { "TelescopeMatching",  { bg = "NONE", fg = "#fb4934", gui = "bold" }},
    { "TelescopeBorder",    { bg = "NONE", fg = "#928374", gui = "bold" }},

    -- diagnostic nvim
    { "LspDiagnosticsDefaultError",         { bg  = "NONE", fg = "#fb4934" }},
    { "LspDiagnosticsDefaultWarning",       { bg  = "NONE", fg = "#d79921" }},
    { "LspDiagnosticsDefaultInformation",   { bg  = "NONE", fg = "#458588" }},
    { "LspDiagnosticsDefaultHint",          { bg  = "NONE", fg = "#689D6A" }},
    { "LspDiagnosticsUnderlineError",       { gui = "underline" }},
    { "LspDiagnosticsUnderlineWarning",     { gui = "underline" }},
    { "LspDiagnosticsUnderlineInformation", { gui = "underline" }},
    { "LspDiagnosticsUnderlineHint",        { gui = "underline" }},

    -- ts override
    -- { "TSKeywordOperator", { bg = "NONE", fg = "#fb4934" }},
    -- { "TSOperator",        { bg = "NONE", fg = "#fe8019" }},
  }

  for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end

  vim.cmd [[ hi ContextUnderline gui=underline guisp=#fb4934 ]]
end

ColorUtil.override_palenight = function()
  local highlights = {
    -- normal stuff
    { "Normal",      { bg  = "NONE" }},
    { "SignColumn",  { bg  = "NONE" }},
    { "Special",     { gui = "NONE" }},
    { "Folded",      { gui = "NONE" }},
    { "EndOfBuffer", { bg  = "NONE" }},
    { "ColorColumn", { bg  = "#32374d" }},
    { "CursorLine",  { bg  = "#32374d" }},

    -- tabline stuff
    { "Tabline",            { bg = "NONE"  }},
    { "TablineSuccess",     { bg = "NONE", fg = "#c3e88d", gui = "bold" }},
    { "TablineError",       { bg = "NONE", fg = "#f07178"  }},
    { "TablineWarning",     { bg = "NONE", fg = "#ffcb6b"  }},
    { "TablineInformation", { bg = "NONE", fg = "#82aaff"  }},
    { "TablineHint",        { bg = "NONE", fg = "#89ddff"  }},

    -- vim-illuminate
    { "illuminatedWord", { gui = "underline" } },

    -- git stuff
    { "SignAdd",    { fg = "#82aaff", bg = "NONE" }},
    { "SignChange", { fg = "#ffcb6b", bg = "NONE" }},
    { "SignDelete", { fg = "#f07178", bg = "NONE" }},

    -- lsp saga stuff
    { "TargetWord",             { fg = "#ffcb6b", bg  = "NONE",    gui = "bold" }},
    { "LspSagaFinderSelection", { fg = "#ffcb6b", bg  = "#292d3e", gui = "bold" }},
    { "LspDiagErrorBorder",     { fg = "#f07178", gui = "bold" }},
    { "LspDiagWarnBorder",      { fg = "#ffcb6b", gui = "bold" }},
    { "LspDiagInfoBorder",      { fg = "#82aaff", gui = "bold" }},
    { "LspDiagHintBorder",      { fg = "#82aaff", gui = "bold" }},

    -- octo.nvim stuff
    { "OctoNvimIssueOpen",         { fg = "#c3e88d" }},
    { "OctoNvimIssueClosed",       { fg = "#f07178" }},
    { "OctoNvimDirty",             { fg = "#f07178" }},
    { "OctoNvimPullAdditions",     { fg = "#c3e88d" }},
    { "OctoNvimPullDeletions",     { fg = "#f07178" }},
    { "OctoNvimPullModifications", { fg = "#ffcb6b" }},

    -- misc
    { "jsonNoQuotesError",     { fg  = "#f07178" }},
    { "jsonMissingCommaError", { fg  = "#f07178" }},
    { "mkdLineBreak",          { bg  = "NONE"    }},
    { "htmlLink",              { gui = "NONE",    fg  = "#82aaff"   }},
    { "IncSearch",             { bg  = "#ffcb6b", fg  = "#292d3e"   }},
    { "mkdLink",               { fg  = "#82aaff", gui = "underline" }},
    { "markdownCode",          { bg  = "NONE",    fg  = "#f07178"   }},
    { "StrikeThrough",         { gui = "strikethrough" }},

    -- statusline colours
    { "StatusLine",   { bg = "#3a405a", fg = "#A6ACCD" }},
    { "StatusLineNC", { bg = "#3a405a", fg = "#828ab7" }},
    { "Mode",         { bg = "#828ab7", fg = "#202331", gui = "bold" }},
    { "LineCol",      { bg = "#414863", fg = "#A6ACCD", gui = "bold" }},
    { "LineColAlt",   { bg = "#3a405a", fg = "#A6ACCD" }},
    { "Git",          { bg = "#828ab7", fg = "#202331", gui = "bold" }},
    { "Filetype",     { bg = "#414863", fg = "#A6ACCD" }},
    { "Filename",     { bg = "#414863", fg = "#A6ACCD" }},
    { "ModeAlt",      { bg = "#414863", fg = "#828ab7" }},
    { "GitAlt",       { bg = "#3a405a", fg = "#414863" }},
    { "FiletypeAlt",  { bg = "#3a405a", fg = "#414863" }},

    -- nvimtree
    { "NvimTreeFolderIcon",   { fg = "#82aaff" }},
    { "NvimTreeIndentMarker", { fg = "#717CB4" }},

    -- telescope
    { "TelescopeSelection", { bg = "NONE", fg = "#82aaff", gui = "bold" }},
    { "TelescopeMatching",  { bg = "NONE", fg = "#f07178", gui = "bold" }},
    { "TelescopeBorder",    { bg = "NONE", fg = "#717CB4", gui = "bold" }},

    -- diagnostic nvim
    { "LspDiagnosticsDefaultError",         { bg  = "NONE", fg = "#f07178" }},
    { "LspDiagnosticsDefaultWarning",       { bg  = "NONE", fg = "#ffcb6b" }},
    { "LspDiagnosticsDefaultInformation",   { bg  = "NONE", fg = "#82aaff" }},
    { "LspDiagnosticsDefaultHint",          { bg  = "NONE", fg = "#c3e88d" }},
    { "LspDiagnosticsUnderlineError",       { gui = "underline" }},
    { "LspDiagnosticsUnderlineWarning",     { gui = "underline" }},
    { "LspDiagnosticsUnderlineInformation", { gui = "underline" }},
    { "LspDiagnosticsUnderlineHint",        { gui = "underline" }},

    -- ts override
    { "TSPunctBracket", { fg = "#ffcb6b" }},
    { "TSConstructor",  { fg = "#ffcb6b" }},
    { "TSTag",          { fg = "#f07178" }},
    { "TSVariable",     { fg = "#A6ACCD" }},
  }

  for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end

  vim.cmd [[ hi ContextUnderline gui=underline guisp=#fb4934 ]]
end

-- italicize comments
set_hl("Comment", { gui = "italic" })

-- automatically override colourscheme
vim.api.nvim_exec([[
  augroup NewColor
  au!
  au ColorScheme gruvbox8 call v:lua.ColorUtil.override_gruvbox()
  au ColorScheme palenight call v:lua.ColorUtil.override_palenight()
  augroup END
]], false)

-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false
vim.cmd [[colorscheme palenight]]

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
