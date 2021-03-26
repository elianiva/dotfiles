vim.cmd [[packadd packer.nvim]]

local ok, packer = pcall(require, "packer")

if ok then
  local use = packer.use

  packer.init {
    git = {
      clone_timeout = 300, -- 5 minutes, I have horrible internet
    },
    display = {
      open_cmd = "80vnew [packer]",
    },
  }

  local plugins = function()
    -- A use-package inspired plugin manager for Neovim.
    use { "wbthomason/packer.nvim", opt = true }

    -- Custom haskell vimscripts
    use { "neovimhaskell/haskell-vim", opt = true, ft = { "haskell" } }

    -- A simplified and optimized Gruvbox colorscheme for Vim
    use { "lifepillar/vim-gruvbox8", opt = false }

    use { "drewtempelmeyer/palenight.vim", opt = false }

    -- commentary.vim: comment stuff out
    use { "tpope/vim-commentary", opt = false }

    -- Project wide Find And Replace Vim plugin
    use { "brooth/far.vim", opt = false }

    -- Wrapper for an external formatter
    use {
      "mhartington/formatter.nvim",
      opt = true,
      cmd = "Format",
    }

    -- The fastest Neovim colorizer.
    use { "norcalli/nvim-colorizer.lua", opt = true }

    -- Nvim Treesitter configurations and abstraction layer
    use {
      "~/repos/nvim-treesitter",
      requires = {
        -- Treesitter playground integrated into Neovim
        { "nvim-treesitter/playground" },

        -- Extra textobjects leveraging Treesitter
        { "nvim-treesitter/nvim-treesitter-textobjects" },

        -- Use treesitter to autoclose and autorename html tag
        { "windwp/nvim-ts-autotag" },

        -- Neovim treesitter plugin for setting the commentstring based on the
        -- cursor location in a file.
        { "JoosepAlviste/nvim-ts-context-commentstring" },
      },
      opt = true,
    }

    -- Auto completion plugin for nvim written in Lua.
    use {
      "~/repos/nvim-compe",
      opt = true,
      requires = {
        -- Snippet plugin for vim/nvim that supports LSP/VSCode's snippet
        -- format. Only used for LSP completion that needs snippet
        { "hrsh7th/vim-vsnip" },
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
    use { "kyazdani42/nvim-web-devicons", opt = true }

    -- Icon set using nonicons for neovim plugins and settings.
    -- requires nonicons font installed
    use { "yamatsum/nvim-nonicons", opt = false }

    -- A file explorer tree for neovim written in lua.
    use { "kyazdani42/nvim-tree.lua", opt = true }

    -- A snazzy bufferline for Neovim
    use { "akinsho/nvim-bufferline.lua", opt = true }

    -- Quickstart configurations for the Nvim LSP client
    use { "neovim/nvim-lspconfig", opt = true }

    -- Utilities to improve the TypeScript development experience for Neovim's
    -- built-in LSP client.
    use { "jose-elias-alvarez/nvim-lsp-ts-utils", opt = false }

    -- Extensions for the built-in LSP support in Neovim for eclipse.jdt.ls
    use { "mfussenegger/nvim-jdtls", opt = false }

    -- Enhance Neovim's builtin LSP UI
    use { "glepnir/lspsaga.nvim", opt = true }

    -- SQLite/LuaJIT binding for lua and neovim
    use { "tami5/sql.nvim", opt = false }

    -- Find, Filter, Preview, Pick. All lua, all the time.
    use {
      "~/repos/telescope.nvim",
      opt = false,
      requires = {
        -- An implementation of the Popup API from vim in Neovim.
        { "nvim-lua/popup.nvim" },

        -- plenary: full; complete; entire; absolute; unqualified.
        { "~/repos/plenary.nvim" },

        -- FZY style sorter that is compiled
        { "nvim-telescope/telescope-fzy-native.nvim" },

        -- Preview media files in Telescope
        { "nvim-telescope/telescope-media-files.nvim" },

        -- A telescope.nvim extension that offers intelligent prioritization
        -- when selecting files from your editing history.
        { "nvim-telescope/telescope-frecency.nvim" },

        -- Search engine integration using Telescope
        {
          "nvim-telescope/telescope-arecibo.nvim",
          rocks = { "openssl", "lua-http-parser" },
        },
      },
    }

    -- Git signs written in pure lua
    use { "lewis6991/gitsigns.nvim", opt = true }

    -- Vim and Neovim plugin to reveal the commit messages under the cursor
    use {
      "rhysd/git-messenger.vim",
      cmd = "GitMessenger",
      opt = true,
    }

    -- The set of operator and textobject plugins to search/select/edit
    -- sandwiched textobjects.
    use { "machakann/vim-sandwich", opt = false }

    -- Embed Neovim in your browser.
    use {
      "glacambre/firenvim",
      run = function() vim.fn["firenvim#install"](0) end,
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
    use { "phaazon/hop.nvim", opt = false }

    -- fix php indent, temporary, will remove this once I'm done with PHP
    use {
      "captbaritone/better-indent-support-for-php-with-html",
      opt = false,
    }

    -- Breakdown Vim's --startuptime output
    use { "tweekmonster/startuptime.vim" }

    -- Magit for Neovim
    use { "TimUntersberger/neogit", opt = false }

    -- Markdown Vim Mode
    use { "plasticboy/vim-markdown", opt = false }

    -- check these out again later
    -- use {'RRethy/vim-illuminate'} -- wait until treesitter priority issue solved
    -- use { "tpope/vim-fugitive", opt = false } -- git helpers inside neovim
    -- use { "lukas-reineke/indent-blankline.nvim", opt = false, branch = "lua" }

  end

  packer.startup(plugins)
end
