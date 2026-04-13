function CustomStatusline()
  -- Diagnostics (shows e.g. "E:2 W:1" when there are issues)
  local diagnostics = ""
  if vim.diagnostic.status then
    local d = vim.diagnostic.status()
    if d and d ~= "" then
      diagnostics = " " .. d
    end
  end

  -- Progress / LSP status (shows "rust-analyzer: Indexing 45%" etc.)
  local progress = ""
  if vim.ui.progress_status then
    local p = vim.ui.progress_status()
    if p and p ~= "" then
      progress = " " .. p
    end
  end

  -- Build the final statusline
  return table.concat({
    "  ",           -- your heart icon
    "%f",           -- filename
    "%m",           -- modified flag [+]
    "%r",           -- readonly flag [RO]
    diagnostics,    -- diagnostic counts
    "%=",           -- switch to right side
    progress,       -- LSP / progress info
    " %y",          -- filetype
    " %l:%c",       -- line:column
  }, " ")
end

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.statusline = "%!v:lua.CustomStatusline()"
    end,
    config = function()
      require("rose-pine").setup {
        variant = "main",
        highlight_groups = {
          -- annoying quickfix line highlight
          QuickFixLine = { fg = "none", bg = "surface" },

          -- pink statusline
          StatusLine = { fg = "love", bg = "love", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "surface" },

          -- less intrusive supermaven suggestion colour
          SupermavenSuggestion = { fg = "muted", blend = 10 },

          -- notify
          NotifyERRORBody = { bg = "surface" },
          NotifyWARNBody = { bg = "surface" },
          NotifyINFOBody = { bg = "surface" },
          NotifyDEBUGBody = { bg = "surface" },
          NotifyTRACEBody = { bg = "surface" },

          -- diagnostics
          DiagnosticSignInfo = { fg = "foam", bg = "surface" },
          DiagnosticSignHint = { fg = "iris", bg = "surface" },
          DiagnosticSignWarn = { fg = "gold", bg = "surface" },
          DiagnosticSignError = { fg = "love", bg = "surface" },

          -- gitsigns
          GitSignsAdd = { fg = "foam" },
          GitSignsChange = { fg = "iris" },
          GitSignsDelete = { fg = "love" },
          GitSignsStagedAdd = { fg = "foam" },
          GitSignsStagedChange = { fg = "iris" },
          GitSignsStagedDelete = { fg = "love" },

          -- dark statuscolumn
          SignColumn = { fg = "muted", bg = "surface" },
          FoldColumn = { fg = "muted", bg = "surface" },
          LineNr = { fg = "muted", bg = "surface" },
          CursorLineNr = { fg = "text", bg = "surface" },
          CursorLineFold = { bg = "surface" },

          -- snacks
          SnacksPicker = { fg = "subtle", bg = "base" },
          SnacksPickerPrompt = { fg = "love", bg = "base" },

          SnacksPickerListTitle = { fg = "base", bg = "love" },
          SnacksPickerListBorder = { fg = "love", bg = "base" },

          SnacksPickerInputTitle = { fg = "base", bg = "pine" },
          SnacksPickerInputBorder = { fg = "pine", bg = "base" },

          FloatTitle = { fg = "base", bg = "pine" },
          SnacksPickerBorder = { fg = "pine", bg = "base" },

          SnacksPickerPreviewTitle = { fg = "base", bg = "iris" },
          SnacksPickerPreviewBorder = { fg = "iris", bg = "base" },

          -- codecompanion
          CodeCompanionChatVariable = { fg = "base", bg = "love" },

          -- better search
          CurSearch = { fg = "base", bg = "love", inherit = false },
          Search = { fg = "text", bg = "love", blend = 20, inherit = false },

          -- flush blink.cmp background
          BlinkCmpMenu = { bg = "base" },
          BlinkCmpMenuBorder = { bg = "base" },
          BlinkCmpMenuSelection = { bg = "love", blend = 10 },

          -- snacks
          SnacksIndent = { fg = "overlay", blend = 10 },
        }
      }
      vim.cmd.colorscheme("rose-pine-dawn")
    end
  },
}
