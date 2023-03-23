return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
    -- "hrsh7th/cmp-nvim-lsp",
    },
    opts = function()
      local map = vim.keymap.set
      local cmp = require("cmp")

      return {
        preselect = cmp.PreselectMode.None,
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          documentation = cmp.config.window.bordered {
            border = {
              "┌", "─", "┐", "│", "┘", "─", "└", "│",
            }
          },
        },
        sources = cmp.config.sources {
          { name = "vsnip" },
          { name = "path" },
          { name = "buffer", keyword_length = 8 },
        },
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item { cmp.SelectBehavior.Select },
          ["<S-Tab>"] = cmp.mapping.select_prev_item { cmp.SelectBehavior.Select },
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
        },
      }
    end
  }
}
