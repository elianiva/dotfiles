vim.cmd[[packadd packer.nvim]]

local ok, packer = pcall(require, "packer")

if ok then
  local use = packer.use

  packer.init({
    git = {
      clone_timeout = 300 -- 5 minutes, I have horrible internet
    },
    display = {
      open_cmd = '80vnew [packer]',
    }
  })

  local plugins = function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    use {'lifepillar/vim-gruvbox8', opt = false} -- nice colorscheme
    -- use {'cohama/lexima.vim', opt = true} -- autopairs brackets, braces etc
    use {'windwp/nvim-autopairs', opt = true} -- autopairs brackets, braces etc
    use {'tomtom/tcomment_vim', opt = false} -- comment stuff easier
    use {'brooth/far.vim', opt = false} -- project wide search and replace
    use {'tpope/vim-fugitive', opt = false} -- git helpers inside neovim
    use {
      'mhartington/formatter.nvim',
      opt = true,
      cmd = "Format"
    } -- comment stuff easier
    use {
      'neoclide/jsonc.vim',
      ft = {'jsonc'},
      opt = true
    } -- jsonc highlighting
    use {'wakatime/vim-wakatime', opt = false} -- track usage time using wakatime
    use {'norcalli/nvim-colorizer.lua', opt = false} -- colorize hex/rgb/hsl value
    use {
      'leafOfTree/vim-svelte-plugin',
      ft = { 'svelte' },
      opt = true,
    } -- svelte language support
    use { '~/repos/nvim-treesitter', opt = true } -- better syntax highlighting
    use { 'nvim-treesitter/playground', opt = true } -- playground for treesitter
    use { 'nvim-treesitter/nvim-treesitter-textobjects', opt = true } -- playground for treesitter
    use {
      'hrsh7th/nvim-compe',
      opt = true,
      requires = {
        {'hrsh7th/vim-vsnip'}, -- integration with vim-vsnip
        {'hrsh7th/vim-vsnip-integ'} -- integration with vim-vsnip
      },
    } -- completion framework
    use {
      'junegunn/goyo.vim',
      ft = {'text', 'markdown'},
      opt = true
    } -- no distraction mode a.k.a zen mode
    use {
      'dhruvasagar/vim-table-mode',
      ft = {'text', 'markdown'},
      opt = true,
    } -- table alignment
    use {
      'kyazdani42/nvim-tree.lua',
      opt = true,
      requires = {
        {'kyazdani42/nvim-web-devicons', opt = true}
      },
    } -- super fast file tree viewer
    use {
      'akinsho/nvim-bufferline.lua',
      opt = true,
      requires = {
        {'kyazdani42/nvim-web-devicons', opt = true}
      }
    } -- snazzy bufferline
    use {'neovim/nvim-lspconfig', opt = false} -- builtin lsp config
    use {
      'mattn/emmet-vim',
      cmd = 'EmmetInstall',
      opt = true
    } -- less typing for html code
    use {
      '~/repos/telescope.nvim',
      requires = {
        {'nvim-lua/popup.nvim'},
        {'nvim-lua/plenary.nvim'},
        {'nvim-telescope/telescope-fzy-native.nvim'}, -- fast finder
        {'~/repos/telescope-media-files.nvim'}, -- media preview
      },
    } -- extensible fuzzy finder
    use {'lewis6991/gitsigns.nvim', opt = true} -- show git stuff in signcolumn
    use {
      'rhysd/git-messenger.vim',
      cmd = 'GitMessenger',
      opt = true
    } -- sort of like git blame but in floating window
    use {'machakann/vim-sandwich', opt = false} -- surround words with symbol
    use {'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end}
    use {
      'mhinz/vim-sayonara',
      cmd = 'Sayonara',
      opt = true
    } -- better window and buffer management
  end

  return packer.startup(plugins)
end
