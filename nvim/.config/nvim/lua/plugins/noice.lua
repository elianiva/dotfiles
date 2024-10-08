return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    views = {
      -- Clean cmdline_popup + palette
      cmdline_popup = {
        position = {
          row = 10,
          col = "50%",
        },
        border = {
          style = "none",
          padding = { 1, 2 },
        },
        size = {
          min_width = 60,
          width = "auto",
          height = "auto",
        },
        win_options = {
          winhighlight = { NormalFloat = "NormalFloat", FloatBorder = "FloatBorder" },
        },
      },
      cmdline_popupmenu = {
        relative = "editor",
        position = {
          row = 13,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
          max_height = 15,
        },
        border = {
          style = "none",
          padding = { 0, 3 },
        },
        win_options = {
          winhighlight = { NormalFloat = "NormalFloat", FloatBorder = "NoiceCmdlinePopupBorder" },
        },
      },
      hover = {
        border = {
          style = "single",
        },
      },
      confirm = {
        border = {
          style = "single",
        },
      },
      popup = {
        border = {
          style = "single",
        },
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
            { find = "fewer lines" },
          },
        },
        view = "mini",
      },
    },
    markdown = {
      hover = {
        ["|(%S-)|"] = vim.cmd.help, -- vim help links
        ["%[.-%]%((%S-)%)"] = function() require("noice.util").open() end, -- markdown links
      },
      highlights = {
        ["|%S-|"] = "@text.reference",
        ["@%S+"] = "@parameter",
        ["^%s*(Parameters:)"] = "@text.title",
        ["^%s*(Return:)"] = "@text.title",
        ["^%s*(See also:)"] = "@text.title",
        ["{%S-}"] = "@parameter",
      },
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
      signature = {
        enabled = true,
        auto_open = {
          enabled = true,
        },
        ---@type NoiceViewOptions
        opts = {
          border = {
            style = require('config.utils').borders
          }
        }
      },
    },
    presets = {
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    notify = {
      enabled = true,
      view = "mini"
    },
    messages = {
      enabled = false,
    }
  },
}
