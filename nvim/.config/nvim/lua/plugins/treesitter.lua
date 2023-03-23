return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
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
        "markdown",
        "lua",
        "python",
        "query",
        "rst",
        "rust",
        "yaml",
        "svelte",
        "tsx",
        "typescript"
      },

      autotag = { enable = true },
      highlight = { enable = vim.g.vscode ~= 1 },
      indent = { enable = true },
      matchup = { enable = true },
      playground = { enable = true },

      context_commentstring = {
        enable = true,
        enable_autocmd = false,
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
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
  }
}
