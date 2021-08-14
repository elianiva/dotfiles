vim.cmd [[ packadd packer.nvim ]]

local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

packer.init {
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
}

local plugins = {
  { "wbthomason/packer.nvim", opt = true },

  require("plugins.nvim-jdtls").plugin,
  require("plugins.rust-tools").plugin,
  require("plugins.flutter-tools").plugin,
  require("plugins.telescope").plugin,
  require("plugins.treesitter").plugin,

  { "tweekmonster/startuptime.vim", cmd = "StartupTime" },

  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require "notify"
      vim.cmd [[
        hi! NotifyERROR      guifg=#e27878
        hi! NotifyWARN       guifg=#e2a478
        hi! NotifyINFO       guifg=#b4be82
        hi! NotifyDEBUG      guifg=#89b8c2
        hi! NotifyTRACE      guifg=#c6c8d1
        hi! NotifyERRORTitle guifg=#e98989
        hi! NotifyWARNTitle  guifg=#e9b189
        hi! NotifyINFOTitle  guifg=#c0ca8e
        hi! NotifyDEBUGTitle guifg=#95c4ce
        hi! NotifyTRACETitle guifg=#d2d4de
      ]]
    end,
  },

  { "tpope/vim-commentary", keys = "gc" },

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

  { "AndrewRadev/splitjoin.vim", keys = "gS" },

  { "dhruvasagar/vim-table-mode", ft = { "text", "markdown" } },

  { "machakann/vim-sandwich", keys = "s" },

  {
    "mhinz/vim-sayonara",
    cmd = "Sayonara",
    setup = function()
      local map = function(lhs, rhs)
        vim.api.nvim_set_keymap("", lhs, rhs, { noremap = true, silent = true })
      end
      map("<A-j>", "<CMD>Sayonara!<CR>")
      map("<A-k>", "<CMD>Sayonara<CR>")
    end,
  },

  {
    "nvim-lua/plenary.nvim",
    module = "plenary",
  },

  {
    "nvim-lua/popup.nvim",
    module = "popup",
  },

  {
    "rktjmp/lush.nvim",
    requires = { "~/Repos/gruvy", "~/Repos/icy" },
    config = function()
      -- require "lush"(require "lush_theme.icy")
      vim.cmd [[ colorscheme icy ]]
    end,
  },

  {
    "folke/which-key.nvim",
    config = function()
      require "plugins.which-key"
    end,
  },

  {
    "ruifm/gitlinker.nvim",
    key = "gy",
    config = function()
      require("gitlinker").setup {
        mappings = "gy",
      }
    end,
  },

  {
    "NTBBloodbath/rest.nvim",
    keys = "<Plug>RestNvim",
    setup = function()
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>rr",
        "<Plug>RestNvim",
        { noremap = false }
      )
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
      {
        "L3MON4D3/LuaSnip",
        module_pattern = { "luasnip", "luasnip.*" },
        config = function()
          require "plugins.luasnip"
        end,
      },
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    wants = { "plenary.nvim" },
    event = "BufRead",
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
    },
  },

  {
    "mfussenegger/nvim-dap",
    keys = "<Leader>d",
    config = function()
      require "modules.dap"
    end,
  },

  {
    "steelsojka/headwind.nvim",
    cmd = { "HeadwindBuf", "HeadwindVisual" },
    setup = function()
      vim.cmd [[
      command! -nargs=0 -range=% HeadwindBuf lua require "headwind".buf_sort_tailwind_classes(0)
      command! -nargs=0 -range=% HeadwindVisual lua require "headwind".sort_tailwind_classes(0)
    ]]
    end,
  },

  {
    "kyazdani42/nvim-web-devicons",
    module = "nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup { default = true }
    end,
  },

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
    config = function()
      require("hop").setup {}
    end,
  },

  {
    "mattn/emmet-vim",
    cmd = "EmmetInstall",
    setup = function()
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_leader_key = ","
    end,
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup {
        window = {
          backdrop = 1, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
          width = 80, -- width of the Zen window
          height = 32, -- height of the Zen window
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
    requires = {
      "sindrets/diffview.nvim",
      cmd = { "DiffViewOpen" },
      module = "diffview",
    },
  },

  {
    "vim-test/vim-test",
    cmd = { "TestFile", "TestNearest", "TestSuite", "TestVisit" },
    setup = function()
      local noremap = function(lhs, rhs)
        vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true })
      end
      noremap("<Leader>tn", "<CMD>TestNearest<CR>")
      noremap("<Leader>tf", "<CMD>TestFile<CR>")
      noremap("<Leader>ts", "<CMD>TestSuite<CR>")
      noremap("<Leader>tl", "<CMD>TestLast<CR>")
      noremap("<Leader>tg", "<CMD>TestVisit<CR>")
      vim.g["test#strategy"] = "neovim"
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
}

packer.startup(function(use)
  for _, v in pairs(plugins) do
    use(v)
  end
end)
