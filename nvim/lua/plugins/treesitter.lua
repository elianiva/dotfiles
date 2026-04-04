return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    }
  },
  branch = "main",
  version = false,
  build = ":TSUpdate",
  lazy = false,
  keys = {
    { "<M-o>", desc = "Increment Selection" },
    { "<M-i>", desc = "Decrement Selection", mode = "x" },
  },
  init = function()
    local ensureInstalled = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "php",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typst",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    }
    local alreadyInstalled = require('nvim-treesitter.config').get_installed()
    local parsersToInstall = vim.iter(ensureInstalled)
      :filter(function(parser)
        return not vim.tbl_contains(alreadyInstalled, parser)
      end)
      :totable()
    require('nvim-treesitter').install(parsersToInstall)
  end,
  config = function(_, opts)
    -- local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    -- parser_config.blade = {
    --   install_info = {
    --     url = "https://github.com/EmranMR/tree-sitter-blade",
    --     files = { "src/parser.c" },
    --     branch = "main",
    --     generate_requires_npm = true,
    --     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
    --   },
    --   filetype = "blade",
    -- }
    -- vim.filetype.add({
    --   pattern = {
    --     [".*%.blade%.php"] = "blade",
    --   },
    -- })

    require("nvim-treesitter").setup({
      sync_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<M-o>",
          node_incremental = "<M-o>",
          node_decremental = "<M-i>",
          scope_incremental = false,
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          -- You can optionally set descriptions to the mappings (used in the desc parameter of
          -- nvim_buf_set_keymap) which plugins like which-key display
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          -- You can also use captures from other query groups like `locals.scm`
          ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
        },
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
      },
    })
  end,
}
