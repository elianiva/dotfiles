vim.cmd [[ packadd packer.nvim ]]

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.cmd [[packadd packer.nvim]]
end

local packer_ok, packer = pcall(require, "packer")

if packer_ok then
  local use = packer.use

  packer.init {
    transitive_opt = false,
    git = {
      clone_timeout = 300, -- 5 minutes, I have horrible internet
    },
    display = {
      open_fn = function()
        return require("packer.util").float({ border = Util.borders })
      end,
    },
  }

  local plugins = function()
    -- A use-package inspired plugin manager for Neovim.
    use { "wbthomason/packer.nvim", opt = true }

    -- A simplified and optimized Gruvbox colorscheme for Vim
    use { "lifepillar/vim-gruvbox8", opt = false }

    -- commentary.vim: comment stuff out
    use { "tpope/vim-commentary", opt = false }

    use { "rktjmp/lush.nvim", opt = false }

    use { "sindrets/diffview.nvim", opt = false }

    use { "~/repos/gruvy", opt = false }

    use { "editorconfig/editorconfig-vim", opt = false }

    -- Sooon...
    -- use {
    --   "vhyrro/neorg",
    --   config = function()
    --     require("neorg").setup {
    --       load = { ["core.defaults"] = {} },
    --     }
    --   end,
    --   requires = { "nvim-lua/plenary.nvim" },
    -- }

    use {
      "mattn/emmet-vim",
      opt = false,
      config = function() require("plugins._emmet") end,
    }

    -- A pretty diagnostics list to help you solve all the trouble your code is
    -- causing.
    use {
      "folke/lsp-trouble.nvim",
      opt = false,
      config = function() require("trouble").setup {} end,
    }

    -- Highlight, list and search todo comments in your projects
    use {
      "folke/todo-comments.nvim",
      opt = false,
      config = function() require("plugins._todo") end,
    }

    use {
      "folke/which-key.nvim",
      opt = false,
      config = function() require("plugins._which-key") end,
    }

    -- Wrapper for an external formatter
    use {
      "mhartington/formatter.nvim",
      opt = false,
      config = function() require("plugins._formatter") end,
    }

    -- The fastest Neovim colorizer.
    use {
      "norcalli/nvim-colorizer.lua",
      opt = true,
      ft = {
        "lua", "html", "css", "typescript",
        "javascript", "svelte", "vim"
      },
      config = function()
        require("colorizer").setup {
          ["*"] = {
            css = true,
            css_fn = true,
            mode = "background",
          },
        }
      end,
    }

    -- Nvim Treesitter configurations and abstraction layer
    use {
      "~/repos/nvim-treesitter",
      opt = false,
      config = function() require("plugins._treesitter") end,
      requires = {
        -- Treesitter playground integrated into Neovim
        { "nvim-treesitter/playground" },

        -- Extra textobjects leveraging Treesitter
        { "nvim-treesitter/nvim-treesitter-textobjects" },

        -- Neovim treesitter plugin for setting the commentstring based on the
        -- cursor location in a file.
        { "JoosepAlviste/nvim-ts-context-commentstring" },
      },
    }

    use {
      "andymass/vim-matchup",
      opt = false,
      config = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
      end
    }

    -- Auto completion plugin for nvim written in Lua.
    use {
      "hrsh7th/nvim-compe",
      opt = false,
      config = function() require("plugins._compe") end,
      requires = {
        -- Snippet plugin for vim/nvim that supports LSP/VSCode's snippet
        -- format. Only used for LSP completion that needs snippet and todo stuff
        {
          "L3MON4D3/LuaSnip",
          config = function() require("plugins._snippets") end,
        },
      },
    }

    -- Distraction-free writing in Vim
    use {
      "junegunn/goyo.vim",
      ft = { "text", "markdown" },
      opt = true,
    }

    -- A Vim alignment plugin
    use {
      "junegunn/vim-easy-align",
      opt = false,
    }

    -- VIM Table Mode for instant table creation.
    use {
      "dhruvasagar/vim-table-mode",
      ft = { "text", "markdown" },
      opt = true,
    }

    -- lua `fork` of vim-web-devicons for neovim
    use {
      "kyazdani42/nvim-web-devicons",
      opt = true,
      requires = {
        -- Icon set using nonicons for neovim plugins and settings.
        -- requires nonicons font installed
        "yamatsum/nvim-nonicons"
      }
    }

    -- A file explorer tree for neovim written in lua.
    use {
      "kyazdani42/nvim-tree.lua",
      opt = false,
      config = function() require("plugins._nvimtree") end,
    }

    -- A snazzy bufferline for Neovim
    use {
      "akinsho/nvim-bufferline.lua",
      opt = false,
      config = function() require("plugins._bufferline") end,
    }

    -- Quickstart configurations for the Nvim LSP client
    use { "neovim/nvim-lspconfig", opt = true }

    -- Tools to help create flutter apps in neovim using the native lsp
    use { "akinsho/flutter-tools.nvim", opt = false }

    -- Tools for better development in rust using neovim's builtin lsp
    use { "simrat39/rust-tools.nvim", opt = false }

    -- lsp signature hint when you type
    use { "ray-x/lsp_signature.nvim", opt = false }

    -- Utilities to improve the TypeScript development experience for Neovim's
    -- built-in LSP client.
    use { "jose-elias-alvarez/nvim-lsp-ts-utils", opt = false }

    -- Extensions for the built-in LSP support in Neovim for eclipse.jdt.ls
    use { "mfussenegger/nvim-jdtls", opt = false }

    -- SQLite/LuaJIT binding for lua and neovim
    use { "tami5/sql.nvim", opt = false }

    -- Find, Filter, Preview, Pick. All lua, all the time.
    use {
      "~/repos/telescope.nvim",
      opt = false,
      config = function() require("plugins._telescope") end,
      requires = {
        -- An implementation of the Popup API from vim in Neovim.
        { "nvim-lua/popup.nvim" },

        -- plenary: full; complete; entire; absolute; unqualified.
        { "nvim-lua/plenary.nvim" },

        -- Preview media files in Telescope
        { "nvim-telescope/telescope-media-files.nvim" },

        -- A telescope.nvim extension that offers intelligent prioritization
        -- when selecting files from your editing history.
        { "nvim-telescope/telescope-frecency.nvim" },

        -- FZF style sorter
        { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },

        -- Search engine integration using Telescope
        -- wait until this one is fixed
        -- {
        --   "nvim-telescope/telescope-arecibo.nvim",
        --   rocks = { "openssl", "lua-http-parser" },
        -- },
      },
    }

    -- Git signs written in pure lua
    use {
      "lewis6991/gitsigns.nvim",
      opt = false,
      config = function() require("plugins._gitsigns") end,
    }

    -- A lua neovim plugin to generate shareable file permalinks
    use {
      "ruifm/gitlinker.nvim",
      opt = false,
      config = function() require("gitlinker").setup {} end,
    }

    -- The set of operator and textobject plugins to search/select/edit
    -- sandwiched textobjects.
    use { "machakann/vim-sandwich", opt = false }

    -- Embed Neovim in your browser.
    use {
      "glacambre/firenvim",
      run = function() vim.fn["firenvim#install"](0) end,
      config = function() require("plugins._firenvim") end,
    }

    -- Sane buffer/window deletion.
    use {
      "mhinz/vim-sayonara",
      cmd = "Sayonara",
      opt = true,
    }

    -- Switch between single-line and multiline forms of code
    use { "AndrewRadev/splitjoin.vim", opt = false }

    -- Github client inside Neovim
    use {
      "pwntester/octo.nvim",
      opt = true,
      cmd = "Octo"
    }

    -- temp, will remove later
    use { "tjdevries/astronauta.nvim", opt = false }

    -- Neovim motions on speed!
    use {
      "phaazon/hop.nvim",
      opt = true,
      cmd = "HopWord",
      config = function() require("hop").setup {} end,
    }

    -- Breakdown Vim's --startuptime output
    use {
      "tweekmonster/startuptime.vim",
      opt = true,
      cmd = "StartupTime",
    }

    -- Magit for Neovim
    use {
      "TimUntersberger/neogit",
      opt = true,
      cond = function()
        return Util.is_git_repo(vim.loop.cwd())
      end,
      config = function ()
        require("neogit").setup {
          disable_signs = false,
          disable_context_highlighting = true,
          signs = {
            -- { CLOSED, OPENED }
            section = { "", "" },
            item = { "+", "-" },
            hunk = { "", "" },
          },
        }
      end
    }

    -- Better markdown support
    use {
      "plasticboy/vim-markdown",
      opt = false,
      filetype = { "markdown" },
      config = function()
        vim.g.vim_markdown_frontmatter = 1
      end
    }

    -- better `gf` movement
    use { "notomo/curstr.nvim", opt = false }

    -- Find the enemy and replace them with dark power.
    use { "windwp/nvim-spectre", opt = false }

    -- Highlights matching word
    use { "RRethy/vim-illuminate" }

    -- A Neovim port of Assorted Biscuits
    -- use { "code-biscuits/nvim-biscuits", opt = false }

    -- check these out again later
    -- use { "tpope/vim-fugitive", opt = false } -- git helpers inside neovim
    -- use { "lukas-reineke/indent-blankline.nvim", opt = false, branch = "lua" }
  end

  packer.startup(plugins)
end
