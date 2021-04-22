vim.api.nvim_exec([[
  packadd nvim-treesitter
  packadd nvim-treesitter-textobjects
  packadd nvim-treesitter-pairs
  packadd playground
  packadd nvim-ts-context-commentstring
]], false)

local ts_config = require("nvim-treesitter.configs")

ts_config.setup {
  ensure_installed = {
    "javascript", "typescript", "tsx", "jsdoc", "cpp", "jsonc",
    "html", "css", "lua", "c", "rust", "go", "java", "query",
    "python", "rst", "svelte"
  },

  highlight = {
    enable = true,
  },

  indent = {
    enable = true,
  },

  autotag = {
    enable = true,
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

  pairs = {
    enable = true,
    highlight_pair_events = { "CursorMoved" }, -- when to highlight the pairs, use {} to deactivate highlighting
    highlight_self = false,
    goto_right_end = false, -- whether to go to the end of the right partner or the beginning
    fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
    keymaps = {
      goto_partner = "%"
    }
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
