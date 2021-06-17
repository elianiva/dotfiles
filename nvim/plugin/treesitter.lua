local ts_config = require("nvim-treesitter.configs")

ts_config.setup {
  ensure_installed = {
    "javascript", "typescript", "tsx", "jsdoc", "cpp", "jsonc",
    "html", "css", "lua", "c", "rust", "go", "java", "query",
    "python", "rst", "svelte", "json", "comment"
  },

  matchup = {
    enable = true,
  },

  highlight = {
    enable = true,
  },

  indent = {
    enable = true, -- wait until it's back to normal
  },

  playground = {
    enable = true,
  },

  context_commentstring = {
    enable = true,
    config = {
      lua = "-- %s",
    }
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
