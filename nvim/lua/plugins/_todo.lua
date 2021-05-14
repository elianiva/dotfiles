require("todo-comments").setup {
  signs = false,
  keywords = {
    FIX  = { icon = " ", color = "warning", alt = { "FIXME", "BUG", "FIXIT", "FIX", "ISSUE" } },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "error" },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  },
  highlight = { before = "", keyword = "fg", after = "" },
  -- list of named colors where we try to extract the guifg from the
  -- list of hilight groups or use the hex color if hl not found as a fallback
  colors = {
    error   = { "LspDiagnosticsDefaultError", "ErrorMsg", "#DC2626" },
    warning = { "LspDiagnosticsDefaultWarning", "WarningMsg", "#FBBF24" },
    info    = { "LspDiagnosticsDefaultInformation", "#2563EB" },
    hint    = { "LspDiagnosticsDefaultHint", "#10B981" },
    default = { "Identifier", "#7C3AED" },
  },
  -- pattern = "(KEYWORDS)\\(.*\\):",
  pattern = "(KEYWORDS:|KEYWORDS\\(.*\\):)",
}
