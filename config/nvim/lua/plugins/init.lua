local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

return packer.startup {
  {
    { "wbthomason/packer.nvim", opt = true },

    { "lewis6991/impatient.nvim" },

    require("plugins.telescope").plugin,

    { "dstein64/vim-startuptime", cmd = "StartupTime" },

    { "tpope/vim-commentary", keys = "gc" },

    { "AndrewRadev/splitjoin.vim", keys = "gS" },

    { "dhruvasagar/vim-table-mode", ft = { "text", "markdown" } },

    { "machakann/vim-sandwich", keys = "s" },

    {
      "~/Repos/nvim-treesitter",
      requires = {
        {
          "nvim-treesitter/playground",
          cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
        },
        "nvim-treesitter/nvim-treesitter-textobjects",
        "windwp/nvim-ts-autotag",
        "JoosepAlviste/nvim-ts-context-commentstring",
      },
    },

    {
      "rcarriga/nvim-notify",
      config = function()
        local notify = require "notify"
        notify.setup {
          stages = "fade",
          timeout = 2500,
          background_colour = "#161822",
        }
        vim.notify = notify
      end,
    },

    {
      "junegunn/vim-easy-align",
      setup = function()
        vim.api.nvim_set_keymap(
          "x",
          "ga",
          "<Plug>(EasyAlign)",
          { noremap = false, silent = true }
        )
      end,
      keys = "<Plug>(EasyAlign)",
    },

    {
      "mhinz/vim-sayonara",
      cmd = "Sayonara",
      setup = function()
        vim.cmd [[
          nnoremap <silent> <A-j> <CMD>Sayonara!<CR>
          nnoremap <silent> <A-k> <CMD>Sayonara<CR>
        ]]
      end,
    },

    { "nvim-lua/plenary.nvim", module = "plenary" },

    { "nvim-lua/popup.nvim", module = "popup" },

    -- {
    --   "~/Repos/icy",
    --   config = function()
    --     vim.cmd [[ colorscheme icy ]]
    --   end,
    -- },

    {
      "~/Repos/gitgud",
      config = function()
        vim.cmd [[ colorscheme gitgud ]]
      end,
    },

    { "rktjmp/lush.nvim", cmd = "Lushify" },

    {
      "folke/which-key.nvim",
      keys = {
        { "n", "<leader>" },
        { "n", "g" },
        { "n", "z" },
      },
      config = function()
        require "plugins.which-key"
      end,
    },

    {
      "kyazdani42/nvim-tree.lua",
      cmd = "NvimTreeToggle",
      config = function()
        require "plugins.nvim-tree"
      end,
    },

    {
      "hrsh7th/nvim-cmp",
      config = function()
        require "plugins.cmp"
      end,
      requires = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",
        "saadparwaiz1/cmp_luasnip",
        {
          "L3MON4D3/LuaSnip",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load {
              paths = vim.fn.stdpath "config" .. "/data/snippets",
            }
            vim.cmd [[
              snoremap <silent> <C-j> <cmd>lua require('luasnip').jump(1)<CR>
              imap <silent><expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-j>'
              snoremap <silent> <C-k> <cmd>lua require('luasnip').jump(-1)<CR>
              inoremap <silent> <C-k> <cmd>lua require('luasnip').jump(-1)<CR>
            ]]
          end,
        },
      },
    },

    {
      "lewis6991/gitsigns.nvim",
      wants = { "plenary.nvim" },
      event = "BufEnter",
      config = function()
        require "plugins.gitsigns"
      end,
    },

    {
      "akinsho/nvim-bufferline.lua",
      config = function()
        require "plugins.nvim-bufferline"
      end,
    },

    {
      "neovim/nvim-lspconfig",
      config = function()
        require "modules.lsp"
      end,
      requires = {
        "jose-elias-alvarez/null-ls.nvim",
        {
          "jose-elias-alvarez/nvim-lsp-ts-utils",
          ft = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
      },
    },

    { "kyazdani42/nvim-web-devicons", module = "nvim-web-devicons" },

    {
      "phaazon/hop.nvim",
      cmd = "HopWord",
      setup = function()
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>w",
          "<CMD>HopWord<CR>",
          { noremap = true }
        )
      end,
    },

    {
      "folke/zen-mode.nvim",
      cmd = "ZenMode",
      config = function()
        require("zen-mode").setup {
          window = {
            backdrop = 1,
            width = 80,
            height = 32,
            linebreak = true,
            wrap = true,
          },
          plugins = {
            options = {
              enabled = true,
              ruler = false,
              showcmd = false,
            },
            gitsigns = { enabled = true }, -- disables git signs
            tmux = { enabled = false }, -- disables the tmux statusline
          },
          on_open = function(win)
            vim.api.nvim_win_set_option(win, "wrap", true)
            vim.api.nvim_win_set_option(win, "linebreak", true)
          end,
        }
      end,
    },

    {
      "plasticboy/vim-markdown",
      filetype = "markdown",
      setup = function()
        vim.g.vim_markdown_folding_disabled = 1
        vim.g.vim_markdown_frontmatter = 1
      end,
    },

    {
      "andymass/vim-matchup",
      setup = function()
        vim.g.matchup_matchparen_offscreen = {
          method = "popup",
          fullwidth = true,
          highlight = "Normal",
        }
      end,
    },

    {
      "TimUntersberger/neogit",
      requires = {
        "sindrets/diffview.nvim",
      },
      cmd = "Neogit",
      config = function()
        require("neogit").setup {
          disable_signs = false,
          disable_context_highlighting = true,
          signs = {
            -- { CLOSED, OPENED }
            section = { "", "" },
            item = { "+", "-" },
            hunk = { "", "" },
          },
          integrations = {
            diffview = true,
          },
        }
      end,
    },

    {
      "vim-test/vim-test",
      cmd = { "TestFile", "TestNearest", "TestSuite", "TestVisit" },
      setup = function()
        require "plugins.vim-test"
      end,
    },

    {
      "lervag/vimtex",
      ft = "latex",
      setup = function()
        vim.g.vimtex_quickfix_enabled = false
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_compiler_latexmk = {
          options = {
            "--shell-escape",
            "-verbose",
            "-file-line-error",
            "-synctex=1",
            "-interaction=nonstopmode",
          },
        }
      end,
    },

    {
      "norcalli/nvim-colorizer.lua",
      cmd = "ColorizerToggle",
      setup = function()
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>c",
          "<CMD>ColorizerToggle<CR>",
          { noremap = true, silent = true }
        )
      end,
      config = function()
        require("colorizer").setup {
          ["*"] = {
            css = true,
            css_fn = true,
            mode = "background",
          },
        }
      end,
    },

    { "mfussenegger/nvim-jdtls" },

    { "akinsho/flutter-tools.nvim" },

    {
      "simrat39/rust-tools.nvim",
      -- wait until rust-tools.nvim adapt to new handler signature
      opt = true,
      wants = { "nvim-lspconfig" },
      config = function()
        require("rust-tools").setup {
          tools = {
            inlay_hints = {
              show_parameter_hints = true,
              parameter_hints_prefix = "  <- ",
              other_hints_prefix = "  => ",
            },
            hover_actions = {
              border = Util.borders,
            },
          },
          server = {
            init_options = {
              detachedFiles = vim.fn.expand "%",
            },
            on_attach = Util.lsp_on_attach,
          },
        }
      end,
    },
  },
  config = {
    compile_path = vim.fn.stdpath "data"
      .. "/site/pack/loader/start/packer.nvim/plugin/packer_compiled.lua",
    git = {
      clone_timeout = 300, -- 5 minutes, I have horrible internet
    },
    display = {
      open_fn = function()
        return require("packer.util").float { border = Util.borders }
      end,
    },
  },
}
