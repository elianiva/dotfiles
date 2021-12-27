local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

return packer.startup {
  {
    {
      "wbthomason/packer.nvim",
      opt = true,
    },

    "lewis6991/impatient.nvim",
    "nathom/filetype.nvim",
    "wakatime/vim-wakatime",
    "gpanders/editorconfig.nvim",

    { "AndrewRadev/splitjoin.vim", keys = "gS" },
    { "machakann/vim-sandwich", keys = "s" },
    { "dstein64/vim-startuptime", cmd = "StartupTime" },

    {
      "andweeb/presence.nvim",
      config = function()
        require("presence"):setup {}
      end,
    },

    {
      "nvim-orgmode/orgmode",
      requires = {
        "nvim-treesitter/nvim-treesitter",
        "akinsho/org-bullets.nvim",
      },
      config = function()
        require("orgmode").setup {
          org_agenda_files = { "~/Dev/org/*" },
          org_default_notes_file = "~/Dev/org/notes.org",
        }
      end,
    },

    {
      "luukvbaal/stabilize.nvim",
      config = function()
        require("stabilize").setup()
      end,
    },

    {
      "ruifm/gitlinker.nvim",
      keys = "<leader>gy",
      requires = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("gitlinker").setup()
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      wants = {
        "plenary.nvim",
        "popup.nvim",
        "telescope-fzf-native.nvim",
        "kyazdani42/nvim-web-devicons",
      },
      requires = {
        "nvim-lua/plenary.nvim",
        "nvim-lua/popup.nvim",
        "kyazdani42/nvim-web-devicons",
        {
          "tami5/sqlite.lua",
          setup = function()
            vim.g.sqlite_clib_path = "/lib64/libsqlite3.so.0.8.6"
          end,
        },
        { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
        "nvim-telescope/telescope-frecency.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
      },
      config = function()
        require("plugins.telescope").config()
      end,
    },

    {
      "numToStr/Comment.nvim",
      keys = "gc",
      requires = {
        "JoosepAlviste/nvim-ts-context-commentstring",
      },
      config = function()
        require("Comment").setup {
          ignore = "^$",
          pre_hook = function()
            return require("ts_context_commentstring.internal").calculate_commentstring()
          end,
        }
      end,
    },

    {
      "https://gitlab.com/yorickpeterse/nvim-pqf",
      config = function()
        require("pqf").setup()
      end,
    },

    {
      "~/Repos/nvim-treesitter",
      config = function()
        require "plugins.nvim-treesitter"
      end,
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
      "junegunn/vim-easy-align",
      keys = "<Plug>(EasyAlign)",
      setup = function()
        vim.api.nvim_set_keymap(
          "x",
          "ga",
          "<Plug>(EasyAlign)",
          { noremap = false, silent = true }
        )
      end,
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

    {
      "~/Repos/gitgud",
      config = function()
        vim.cmd [[colorscheme gitgud]]
      end,
    },

    {
      "rktjmp/shipwright.nvim",
      cmd = "Shipwright",
      module_pattern = { "shipwright", "shipwright.*" },
    },

    {
      "rktjmp/lush.nvim",
      cmd = "Lushify",
      module_pattern = { "lush", "lush.*" },
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
          setup = function()
            vim.cmd [[
            " Jump forward or backward
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
      event = "BufEnter", -- don't need this on scratch buffer
      wants = {
        "plenary.nvim",
      },
      requires = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require "plugins.gitsigns"
      end,
    },

    {
      "akinsho/nvim-bufferline.lua",
      requires = {
        "kyazdani42/nvim-web-devicons",
      },
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

    {
      "phaazon/hop.nvim",
      cmd = "HopWord",
      config = function()
        require("hop").setup()
      end,
      setup = function()
        vim.api.nvim_set_keymap(
          "n",
          "<Leader>w",
          "<CMD>HopWord<CR>",
          { noremap = true, silent = true }
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
      cmd = "Neogit",
      requires = {
        "sindrets/diffview.nvim",
      },
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
      "norcalli/nvim-colorizer.lua",
      cmd = "ColorizerToggle",
      setup = function()
        vim.cmd [[ nnoremap <silent> <Leader>c <CMD>ColorizerToggle<CR> ]]
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

    -- not doing flutter atm
    -- { "akinsho/flutter-tools.nvim" },

    {
      "simrat39/rust-tools.nvim",
      requires = {
        "neovim/nvim-lspconfig",
      },
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

    -- not writing any latex atm
    -- {
    --   "lervag/vimtex",
    --   ft = "latex",
    --   setup = function()
    --     vim.g.vimtex_quickfix_enabled = false
    --     vim.g.vimtex_view_method = "zathura"
    --     vim.g.vimtex_compiler_latexmk = {
    --       options = {
    --         "--shell-escape",
    --         "-verbose",
    --         "-file-line-error",
    --         "-synctex=1",
    --         "-interaction=nonstopmode",
    --       },
    --     }
    --   end,
    -- },
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