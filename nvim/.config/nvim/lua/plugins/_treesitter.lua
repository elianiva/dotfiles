vim.cmd[[packadd nvim-treesitter]]
vim.cmd[[packadd nvim-treesitter-textobjects]]
vim.cmd[[packadd playground]]

local ts_config = require("nvim-treesitter.configs")
local parser_config = require"nvim-treesitter.parsers".get_parser_configs()

parser_config.svelte = {
  install_info = {
    url = "~/repos/tree-sitter-svelte",
    files = {"src/parser.c", "src/scanner.cc"}
  },
  filetype = "svelte",
  used_by = {"svelte"}
}

parser_config.javascript = {
  install_info = {
    url = "~/repos/tree-sitter-js-svelte", -- fork of js parser with svelte stuff
    files = {"src/parser.c", "src/scanner.c"}
  },
  filetype = {"javascript", "javascriptreact"},
  used_by = {"js", "jsx"}
}

ts_config.setup {
  ensure_installed = {
    "javascript", "typescript", "tsx", "jsdoc",
    "html", "css", "lua", "c", "rust", "go", "java"
  },

  highlight = {
    enable = true,
  },

  indent = {
    enable = true,
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
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    lsp_interop = {
      enable = true,
    },
  },
}
