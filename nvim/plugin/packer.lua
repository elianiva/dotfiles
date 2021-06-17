local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

packer.init {
  transitive_opt = false,
  git = {
    clone_timeout = 300, -- 5 minutes, I have horrible internet
  },
  display = {
    open_fn = function()
      return require("packer.util").float { border = Util.borders }
    end,
  },
}

local plugins = {
  -- let packer manage itself
  { "wbthomason/packer.nvim" },

  { "Olical/conjure", tag = "v4.21.0" },
  { "Olical/aniseed", tag = "v3.19.0" },

  -- colorscheme
  { "rktjmp/lush.nvim", requires = { "~/repos/gruvy", "~/repos/icy" } },

  -- better markdown support
  {
    "plasticboy/vim-markdown",
    opt = true,
    filetype = { "markdown" },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_frontmatter = 1
    end,
  },

  -- The fastest Neovim colorizer.
  {
    "norcalli/nvim-colorizer.lua",
    opt = true,
    ft = { "lua", "html", "css", "vim", "typescript", "javascript", "svelte" },
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
  -- cheatsheet for keybinds
  { "folke/which-key.nvim" },
  -- treesitter abstraction layer
  {
    "~/repos/nvim-treesitter",
    requires = {
      -- debug stuff
      {
        "nvim-treesitter/playground",
        opt = true,
        cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" },
      },
      -- moar textobjects
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- context aware commentstring
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  },
  -- lua `fork` of vim-web-devicons for neovim
  {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup { default = true }
    end,
    requires = {
      -- requires nonicons font installed
      "yamatsum/nvim-nonicons",
    },
  },
  -- file tree explorer
  { "kyazdani42/nvim-tree.lua" },

  -- bufferline
  { "akinsho/nvim-bufferline.lua" },

  -- Single tabpage interface to easily cycle through diffs for all modified
  -- files for any git rev.
  { "sindrets/diffview.nvim" },

  -- Git signs written in pure lua
  { "lewis6991/gitsigns.nvim" },

  -- Magit for Neovim
  {
    "TimUntersberger/neogit",
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

  -- nvim lsp config abstraction layer
  { "neovim/nvim-lspconfig" },

  -- DAP client for neovim
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "modules.dap"
    end,
  },

  -- Tools to help create flutter apps in neovim using the native lsp
  { "akinsho/flutter-tools.nvim" },

  -- Tools for better development in rust using neovim's builtin lsp
  { "simrat39/rust-tools.nvim" },

  -- lsp signature hint when you type
  { "ray-x/lsp_signature.nvim" },

  -- Utilities to improve the TypeScript development experience for Neovim's
  -- built-in LSP client.
  { "jose-elias-alvarez/nvim-lsp-ts-utils" },

  -- Use Neovim as a language server to inject LSP diagnostics, code actions,
  -- and more via Lua.
  { "jose-elias-alvarez/null-ls.nvim" },

  -- Extensions for the built-in LSP support in Neovim for eclipse.jdt.ls
  { "mfussenegger/nvim-jdtls" },

  -- autocompletion
  {
    "hrsh7th/nvim-compe",
    requires = {
      -- snippets integration
      { "L3MON4D3/LuaSnip" },
    },
  },

  -- Find, Filter, Preview, Pick. All lua, all the time.
  {
    "~/repos/telescope.nvim",
    config = function()
      require "modules._telescope"
    end,
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

      -- Integration for nvim-dap with telescope.nvim
      { "nvim-telescope/telescope-dap.nvim" },

      -- Search engine integration using Telescope
      -- wait until this one is fixed
      -- {
      --   "nvim-telescope/telescope-arecibo.nvim",
      --   rocks = { "openssl", "lua-http-parser" },
      -- },
    },
  },

  -- SQLite/LuaJIT binding for lua and neovim
  { "tami5/sql.nvim" },

  -- Embed Neovim in your browser.
  {
    "glacambre/firenvim",
    run = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      if vim.fn.exists("g:started_by_firenvim") == 1 then
        vim.cmd [[
          set laststatus=0
          set showtabline=0
          set guifont=JetBrainsMono:h11
        ]]
      end
      vim.g.firenvim_config = {
        localSettings = {[".*"] = { takeover = "never", priority = 1 }},
      }
    end
  },

  -- Breakdown Vim's --startuptime output
  {
    "tweekmonster/startuptime.vim",
    opt = true,
    cmd = "StartupTime",
  },

  -- VimTeX: A modern Vim and neovim filetype plugin for LaTeX files.
  {
    "lervag/vimtex",
    config = function()
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

  -- comment stuff out
  { "tpope/vim-commentary" },

  -- sort tailwind classes
  { "steelsojka/headwind.nvim" },

  -- A fast Neovim http client written in Lua
  { "NTBBloodbath/rest.nvim" },

  -- Emmet for vim
  {
    "mattn/emmet-vim",
    config = function()
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_leader_key = ","
    end,
  },

  -- A Vim alignment plugin
  { "junegunn/vim-easy-align" },

  -- Neovim motions on speed!
  {
    "phaazon/hop.nvim",
    opt = true,
    cmd = "HopWord",
    config = function()
      require("hop").setup {}
    end,
  },

  -- Switch between single-line and multiline forms of code
  { "AndrewRadev/splitjoin.vim" },

  -- VIM Table Mode for instant table creation.
  {
    "dhruvasagar/vim-table-mode",
    ft = { "text", "markdown" },
    opt = true,
  },

  -- The set of operator and textobject plugins to search/select/edit
  -- sandwiched textobjects.
  { "machakann/vim-sandwich" },

  -- even better %
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

  -- Sane buffer/window deletion.
  {
    "mhinz/vim-sayonara",
    opt = true,
    cmd = "Sayonara",
  },

  -- better `gf` movement
  { "notomo/curstr.nvim" },

  -- {{{ UNUSED, CHECK LATER
  -- A Neovim port of Assorted Biscuits
  -- { "code-biscuits/nvim-biscuits" },

  -- check these out again later
  -- { "RRethy/vim-illuminate" },
  -- { "tpope/vim-fugitive" } -- git helpers inside neovim
  -- { "lukas-reineke/indent-blankline.nvim", branch = "lua" },

  -- Sooon...
  -- {
  --   "vhyrro/neorg",
  --   config = function()
  --     require("neorg").setup {
  --       load = { ["core.defaults"] = {} },
  --     },
  --   end,
  --   requires = { "nvim-lua/plenary.nvim" },
  -- },
  -- }}},
}

packer.startup(function(use)
  for _, v in pairs(plugins) do
    use(v)
  end
end)
