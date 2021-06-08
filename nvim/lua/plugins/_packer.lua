vim.cmd [[ packadd packer.nvim ]]

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({
    "git", "clone", "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.cmd [[packadd packer.nvim]]
end

local packer_ok, packer = pcall(require, "packer")
if not packer_ok then return end

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

-- {{{ UI RELATED PLUGINS
  -- my custom colourscheme based on gruvbox
  use {
    "~/repos/gruvy",
    opt = false,
    requires = { "rktjmp/lush.nvim" },
  }

  -- Better markdown support
  use {
    "plasticboy/vim-markdown",
    opt = true,
    filetype = { "markdown" },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_frontmatter = 1
    end
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

  -- Highlight, list and search todo comments in your projects
  use {
    "folke/todo-comments.nvim",
    opt = false,
    config = function() require("plugins._todo") end,
  }

  -- Create key bindings that stick
  use {
    "folke/which-key.nvim",
    opt = false,
    config = function() require("plugins._which-key") end,
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
-- }}}

-- {{{ GIT RELATED PLUGINS
  -- Single tabpage interface to easily cycle through diffs for all modified
  -- files for any git rev.
  use { "sindrets/diffview.nvim", opt = false }

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

  -- Github client inside Neovim
  use {
    "pwntester/octo.nvim",
    opt = true,
    cmd = "Octo"
  }

  -- Magit for Neovim
  use {
    "TimUntersberger/neogit",
    opt = false,
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
        integrations = {
          diffview = true
        }
      }
    end
  }
-- }}}

-- {{{ LSP AND DAP RELATED PLUGINS
  -- Quickstart configurations for the Nvim LSP client
  use {
    "neovim/nvim-lspconfig",
    opt = false,
  }

  -- Wrapper for an external formatter
  use {
    "mhartington/formatter.nvim",
    opt = false,
    config = function() require("plugins._formatter") end,
  }

  -- Debug Adapter Protocol client implementation for Neovim (>= 0.5)
  use {
    "mfussenegger/nvim-dap",
    opt = false,
    config = function() require("modules.dap") end,
    requires = { "rcarriga/nvim-dap-ui" },
  }

  -- Tools to help create flutter apps in neovim using the native lsp
  use { "akinsho/flutter-tools.nvim", opt = false }

  -- Tools for better development in rust using neovim's builtin lsp
  use { "simrat39/rust-tools.nvim", opt = false }

  -- lsp signature hint when you type
  use { "ray-x/lsp_signature.nvim", opt = false }

  -- Utilities to improve the TypeScript development experience for Neovim's
  -- built-in LSP client.
  use { "jose-elias-alvarez/nvim-lsp-ts-utils", opt = false }

  -- Use Neovim as a language server to inject LSP diagnostics, code actions,
  -- and more via Lua.
  use { "jose-elias-alvarez/null-ls.nvim", opt = false }

  -- Extensions for the built-in LSP support in Neovim for eclipse.jdt.ls
  use { "mfussenegger/nvim-jdtls", opt = false }

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
-- }}}

-- {{{ TELESCOPE RELATED PLUGINS
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

      -- Integration for nvim-dap with telescope.nvim
      { "nvim-telescope/telescope-dap.nvim" },

      -- Search engine integration using Telescope
      -- wait until this one is fixed
      -- {
      --   "nvim-telescope/telescope-arecibo.nvim",
      --   rocks = { "openssl", "lua-http-parser" },
      -- },
    },
  }

  -- SQLite/LuaJIT binding for lua and neovim
  use { "tami5/sql.nvim", opt = false }
-- }}}

-- {{{ OTHER STUFF
  -- editorconfig support
  use { "editorconfig/editorconfig-vim", opt = false }

  -- Embed Neovim in your browser.
  use {
    "glacambre/firenvim",
    run = function() vim.fn["firenvim#install"](0) end,
    config = function() require("plugins._firenvim") end,
  }

  -- Breakdown Vim's --startuptime output
  use {
    "tweekmonster/startuptime.vim",
    opt = true,
    cmd = "StartupTime",
  }
-- }}}

-- {{{ UTILITY PLUGINS
  -- commentary.vim: comment stuff out
  use { "tpope/vim-commentary", opt = false }

  -- A fast Neovim http client written in Lua
  use { "NTBBloodbath/rest.nvim", opt = false }

  -- A Vim alignment plugin
  use { "junegunn/vim-easy-align", opt = false }

  use {
    "steelsojka/pears.nvim",
    config = function() require("plugins._pears") end
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

  -- Switch between single-line and multiline forms of code
  use { "AndrewRadev/splitjoin.vim", opt = false }

  -- VIM Table Mode for instant table creation.
  use {
    "dhruvasagar/vim-table-mode",
    ft = { "text", "markdown" },
    opt = true,
  }

  -- The set of operator and textobject plugins to search/select/edit
  -- sandwiched textobjects.
  use { "machakann/vim-sandwich", opt = false }

  -- even better %
  use {
    "andymass/vim-matchup",
    opt = false,
    config = function()
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
        fullwidth = true,
        highlight = "Normal"
      }
    end
  }

  -- Sane buffer/window deletion.
  use {
    "mhinz/vim-sayonara",
    opt = true,
    cmd = "Sayonara",
  }

  -- better `gf` movement
  use { "notomo/curstr.nvim", opt = false }
-- }}}

-- {{{ UNUSED, CHECK LATER
  -- A Neovim port of Assorted Biscuits
  -- use { "code-biscuits/nvim-biscuits", opt = false }

  -- check these out again later
  -- use { "RRethy/vim-illuminate" }
  -- use { "tpope/vim-fugitive", opt = false } -- git helpers inside neovim
  -- use { "lukas-reineke/indent-blankline.nvim", opt = false, branch = "lua" }

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
-- }}}

end

packer.startup(plugins)
