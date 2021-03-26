vim.cmd [[packadd nvim-treesitter]]
vim.cmd [[packadd nvim-treesitter-textobjects]]
vim.cmd [[packadd playground]]
vim.cmd [[packadd nvim-ts-autotag]]
vim.cmd [[packadd nvim-ts-context-commentstring]]

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
    disable = { "javascript", "typescript" }
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
