local M = {}

M.plugin = {
  "~/Repos/nvim-treesitter",
  requires = {
    -- debug stuff
    {
      "nvim-treesitter/playground",
      cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
    },

    -- moar textobjects
    "nvim-treesitter/nvim-treesitter-textobjects",

    -- context aware commentstring
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    require("plugins.treesitter").config()
  end,
}

M.config = function()
  local ts_config = require "nvim-treesitter.configs"

  ts_config.setup {
    ensure_installed = {
      "c",
      "comment",
      "cpp",
      "css",
      "glimmer",
      "go",
      "html",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "lua",
      "nix",
      "python",
      "query",
      "rst",
      "rust",
      "svelte",
      "tsx",
      "typescript",
    },

    matchup = { enable = true },
    highlight = { enable = true },
    indent = { enable = false }, -- wait until it's back to normal
    playground = { enable = true },

    context_commentstring = {
      enable = true,
      config = {
        lua = "-- %s",
      },
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<Enter>",
        node_incremental = "<Enter>",
        node_decremental = "<BS>",
      },
    },

    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<Leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<Leader>A"] = "@parameter.inner",
        },
      },
      lsp_interop = {
        enable = true,
      },
    },
  }
end

return M
