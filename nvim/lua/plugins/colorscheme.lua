return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    init = function()
      vim.opt.laststatus = 3 -- Or 3 for global statusline
      vim.opt.statusline = " %f %m %r %= %y %l:%c   "
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
          SnacksPickerListTitle = { fg = "base", bg = "love" },
          SnacksPickerListBorder = { fg = "love", bg = "base" },
          SnacksPickerInputTitle = { fg = "base", bg = "pine" },
          SnacksPickerInputBorder = { fg = "pine", bg = "base" },
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
          SnacksIndent = { fg = "highlight_high", blend = 10 },
        }
      }
      vim.cmd.colorscheme("rose-pine-dawn")
    end
  },
}
