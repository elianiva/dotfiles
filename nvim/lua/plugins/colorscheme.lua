return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    init = function()
      vim.opt.laststatus = 3 -- Or 3 for global statusline
      vim.opt.statusline = " ♥  %f %m %r %= %y %l:%c   "
    end,
    config = function()
      require("rose-pine").setup {
        variant = "main",
        highlight_groups = {
          -- pink statusline
          StatusLine = { fg = "love", bg = "love", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "surface" },

          -- notify
          NotifyERRORBody = { bg = "surface" },
          NotifyWARNBody = { bg = "surface" },
          NotifyINFOBody = { bg = "surface" },
          NotifyDEBUGBody = { bg = "surface" },
          NotifyTRACEBody = { bg = "surface" },

          -- dark statuscolumn
          SignColumn = { fg = "muted", bg = "surface" },
          FoldColumn = { fg = "muted", bg = "surface" },
          LineNr = { fg = "muted", bg = "surface" },
          CursorLineNr = { fg = "text", bg = "surface" },
          CursorLineFold = { bg = "surface" },

          -- telescope
          TelescopeBorder = { fg = "overlay", bg = "overlay" },
          TelescopeNormal = { fg = "subtle", bg = "overlay" },
          TelescopeSelection = { fg = "text", bg = "highlight_med" },
          TelescopeSelectionCaret = { fg = "love", bg = "highlight_med" },
          TelescopeMultiSelection = { fg = "text", bg = "highlight_high" },

          TelescopeTitle = { fg = "base", bg = "love" },
          TelescopePromptTitle = { fg = "base", bg = "pine" },
          TelescopePreviewTitle = { fg = "base", bg = "iris" },

          TelescopePromptNormal = { fg = "text", bg = "surface" },
          TelescopePromptBorder = { fg = "surface", bg = "surface" },

          -- better search
          CurSearch = { fg = "base", bg = "love", inherit = false },
          Search = { fg = "text", bg = "love", blend = 20, inherit = false },
        }
      }
      vim.cmd.colorscheme("rose-pine")
    end
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    enabled = false,
    config = function()
      local c = require('vscode.colors').get_colors()
      local dark = "#181818";
      require("vscode").setup {
        italic_comments = true,
        underline_links = true,
        group_overrides = {
          FloatBorder = { bg = "NONE", fg = c.vscLineNumber },
          PMenu = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          SignColumn = { fg = c.vscLineNumber, bg = dark },
          FoldColumn = { fg = c.vscLineNumber, bg = dark },
          LineNr = { fg = c.vscLineNumber, bg = dark },
          CursorLineNr = { fg = c.vscFront, bg = dark },
          CursorLineFold = { bg = dark },
        }
      }
      require("vscode").load()
      vim.cmd [[
        hi link BlinkCmpKindFolder BlinkCmpKindFile
        hi link BlinkCmpFloatBorder FloatBorder
        hi link BlinkCmpMenuBorder FloatBorder
      ]]
    end,
  },
}
