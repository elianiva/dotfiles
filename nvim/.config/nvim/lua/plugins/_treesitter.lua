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

ts_config.setup {
  ensure_installed = {
    "javascript", "typescript", "tsx", "jsdoc", "cpp", "jsonc",
    "html", "css", "lua", "c", "rust", "go", "java", "query",
    "python", "rst"
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
