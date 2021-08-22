local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

return packer.startup {
  {
    { "wbthomason/packer.nvim", opt = true },

    require("plugins.telescope").plugin,

    { "tweekmonster/startuptime.vim", cmd = "StartupTime" },

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
        vim.notify = require "notify"
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

    {
      "rktjmp/lush.nvim",
      requires = { "~/Repos/icy" },
      config = function()
        vim.cmd [[ colorscheme icy ]]
      end,
    },

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
        "hrsh7th/cmp-vsnip",
        {
          "hrsh7th/vim-vsnip",
          opt = false,
          setup = function()
            vim.g.vsnip_snippet_dir = vim.fn.stdpath "config"
              .. "/data/snippets"
            vim.g.vsnip_filetypes = {}
            vim.g.vsnip_filetypes.javascript = {
              "javascript",
              "javascriptreact",
              "typescriptreact",
            }
            vim.cmd [[
              imap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
              smap <expr> <C-j> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-j>'
              imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
              smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
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
        "jose-elias-alvarez/nvim-lsp-ts-utils",
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
      "tpope/vim-fugitive",
      cmd = { "G", "Git", "Gdiffsplit", "GBrowse" },
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
    { "simrat39/rust-tools.nvim", wants = { "nvim-lspconfig" } },
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
