local set_hl = require("modules._util").set_hl

ColorUtil = {}

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
  au ColorScheme onedark call v:lua.ColorUtil.override_onedark()
  augroup END
]], false)

-- set colourscheme
require('lush')(require('lush_theme.gruvy'))

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