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
    use { "wbthomason/packer.nvim", opt = true } -- plugin manager

    use { "lifepillar/vim-gruvbox8", opt = false } -- nice colorscheme
    use { "embark-theme/vim", opt = false } -- demo stuff
    use { "windwp/nvim-autopairs", opt = true } -- autopairs brackets, braces etc
    use { "b3nj5m1n/kommentary", opt = true } -- comment stuff easier
    use { "brooth/far.vim", opt = false } -- project wide search and replace
    use { "tpope/vim-fugitive", opt = false } -- git helpers inside neovim
    use {
      "mhartington/formatter.nvim",
      opt = true,
      cmd = "Format",
    } -- helper for fast formatting
    use { "norcalli/nvim-colorizer.lua", opt = true } -- colorize hex/rgb/hsl value
    use {
      "~/repos/nvim-treesitter",
      requires = {
        { "nvim-treesitter/playground" }, -- playground for treesitter
        { "nvim-treesitter/nvim-treesitter-textobjects" }, -- "smart" textobjects
      },
      opt = true,
    } -- mostly for better syntax highlighting, but it has more stuff
    use {
      "~/repos/nvim-compe",
      opt = true,
      requires = {
        { "hrsh7th/vim-vsnip" }, -- integration with vim-vsnip
      },
    } -- completion framework
    use {
      "junegunn/goyo.vim",
      ft = { "text", "markdown" },
      opt = true,
    } -- no distraction mode a.k.a zen mode
    use {
      "junegunn/vim-easy-align",
      opt = false,
    } -- easy align using delimiter
    use {
      "dhruvasagar/vim-table-mode",
      ft = { "text", "markdown" },
      opt = true,
    } -- table alignment
    use { "kyazdani42/nvim-web-devicons", opt = true } -- fancy icons
    use { "kyazdani42/nvim-tree.lua", opt = true } -- super fast file tree viewer
    use { "akinsho/nvim-bufferline.lua", opt = true } -- snazzy bufferline
    use { "neovim/nvim-lspconfig", opt = true } -- builtin lsp config
    use { "mfussenegger/nvim-jdtls", opt = false } -- jdtls
    use { "glepnir/lspsaga.nvim", opt = true } -- better UI for builtin LSP
    use { "windwp/nvim-ts-autotag", opt = true } -- auto-close html tag
    use { "tami5/sql.nvim", opt = false } -- sql bindings in LuaJIT
    use {
      "~/repos/telescope.nvim",
      opt = false,
      requires = {
        { "nvim-lua/popup.nvim" },
        { "~/repos/plenary.nvim" }, -- more stdlib
        { "nvim-telescope/telescope-fzy-native.nvim" }, -- fast search algo
        { "nvim-telescope/telescope-media-files.nvim" }, -- media preview
        { "nvim-telescope/telescope-frecency.nvim" }, -- media preview
        {
          "~/repos/telescope-arecibo.nvim",
          rocks = { "openssl", "lua-http-parser" },
        },
      },
    } -- extensible fuzzy finder
    use { "lewis6991/gitsigns.nvim", opt = true } -- show git stuff in signcolumn
    use {
      "rhysd/git-messenger.vim",
      cmd = "GitMessenger",
      opt = true,
    } -- sort of like git blame but in floating window
    use { "machakann/vim-sandwich", opt = false } -- surround words with symbol
    use {
      "glacambre/firenvim",
      run = function() vim.fn["firenvim#install"](0) end,
    }
    use {
      "mhinz/vim-sayonara",
      cmd = "Sayonara",
      opt = true,
    } -- better window and buffer management
    use { "AndrewRadev/splitjoin.vim", opt = false }
    use {
      "pwntester/octo.nvim",
      opt = true,
      cmd = "Octo"
    } -- TUI github client
    use { "tjdevries/astronauta.nvim", opt = false } -- temporary stuff before it got merged upstream
    use { "phaazon/hop.nvim", opt = false } -- easymotion but better
    use {
      "captbaritone/better-indent-support-for-php-with-html",
      opt = false,
    } -- hhhhhhhh
    use { "tweekmonster/startuptime.vim" }

    -- check these out again later
    -- use {'RRethy/vim-illuminate'} -- wait until treesitter priority issue solved
    -- use {'TimUntersberger/neogit', opt = false} -- magit clone, use this later when it's more stable
  end

  packer.startup(plugins)
end
