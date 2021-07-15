local M = {}

M.plugin = {
  "~/repos/nvim-treesitter",
  event = "BufRead",
  opt = true,
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

  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.svelte = {
    install_info = {
      url = "~/repos/tree-sitter-svelte",
      files = {"src/parser.c", "src/scanner.c"}
    },
    filetype = "svelte", -- if filetype does not agrees with parser name
    used_by = {"svelte"} -- additional filetypes that use this parser
  }

  ts_config.setup {
    ensure_installed = {
      "javascript",
      "typescript",
      "tsx",
      "jsdoc",
      "cpp",
      "jsonc",
      "html",
      "css",
      "lua",
      "c",
      "rust",
      "go",
      "java",
      "query",
      "python",
      "rst",
      -- "svelte",
      "json",
      "comment",
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
