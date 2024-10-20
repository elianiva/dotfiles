return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    config = function()
      local c = require('vscode.colors').get_colors()
      local dark = "#181818";
      require("vscode").setup {
        italic_comments = true,
        underline_links = true,
        group_overrides = {
          FloatBorder = { bg = "NONE", fg = c.vscLineNumber },
          SignColumn = { fg = c.vscLineNumber, bg = dark },
          FoldColumn = { fg = c.vscLineNumber, bg = dark },
          PMenu = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          CursorLineNr = { fg = c.vscFront, bg = dark },
          LineNr = { fg = c.vscLineNumber, bg = dark },
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
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
  }
}
