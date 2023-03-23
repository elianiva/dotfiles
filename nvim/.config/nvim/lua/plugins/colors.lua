return {
    {
        "Mofiqul/vscode.nvim",
        opts = {
            -- Enable italic comment
            italic_comments = true,

            -- Override colors (see ./lua/vscode/colors.lua)
            color_overrides = {
                vscBack = "#181818",
                vscFront = "#c7c9d1",
                vscCursorDarkDark = "#1f1f1f",
                vscSelection = "#192044",
                vscPopupHighlightBlue = "#192044",
                vscPopupFront = "#3a3e56",
                vscPopupBack = "#262837",
                vscSplitDark = "#3a3e56",
                vscLineNumber = "#252735"
            },

            group_overrides = {
                -- NonText = { fg = require("vscode.colors").vscLineNumber, bg = "NONE" },
                -- PMenu = { fg = require("vscode.colors").vscFront, bg = "#262837" },
                -- PMenuSel = { bg = "#3A3E56" },
                -- PMenuSbar = { bg = require("vscode.colors").vscPopupBack },
                PMenuSthumb = { bg = "#3A3E56" },
                SignAdd = { fg = "#a7da1e" },
                SignDelete = { fg = "#e61f44" },
                SignChange = { fg = "#f7b83d" }
            }
        },
        config = function(_, opts)
            require("vscode").setup(opts)
            vim.cmd [[ colorscheme vscode ]]
        end
    }
}
