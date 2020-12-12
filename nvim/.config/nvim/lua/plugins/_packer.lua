vim.cmd[[packadd packer.nvim]]

local ok, packer = pcall(require, "packer")

if ok then
  local use = packer.use

  packer.init({
    git = {
      clone_timeout = 300 -- 5 minutes, I have horrible internet
    }
  })

  local plugins = function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    use 'gruvbox-community/gruvbox' -- nice colorscheme
    use 'cohama/lexima.vim' -- autopairs brackets, braces etc
    use 'tpope/vim-commentary' -- comment stuff easier
    use {
      'neoclide/jsonc.vim',
      ft = {'jsonc'},
      opt = true
    } -- jsonc highlighting
    use 'wakatime/vim-wakatime' -- track usage time using wakatime
    use 'norcalli/nvim-colorizer.lua' -- colorize hex/rgb/hsl value
    use {
      'leafOfTree/vim-svelte-plugin',
      ft = { 'svelte' },
      requires = {
        {'pangloss/vim-javascript', ft = { 'svelte' }, opt = true},
      },
      opt = true
    } -- svelte language support
    use {'nvim-treesitter/nvim-treesitter', opt = true } -- better syntax highlighting
    use { 'nvim-treesitter/playground', opt = true } -- playground for treesitter
    use {
      'hrsh7th/nvim-compe',
      requires = {
        {'hrsh7th/vim-vsnip'}, -- integration with vim-vsnip
        {'hrsh7th/vim-vsnip-integ'} -- integration with vim-vsnip
      }
    } -- completion framework
    use {
      'junegunn/goyo.vim',
      ft = {'txt', 'markdown'},
      opt = true
    } -- no distraction mode a.k.a zen mode
    use {
      'dhruvasagar/vim-table-mode',
      ft = {'txt', 'markdown'},
      opt = true,
    } -- table alignment
    use {
      'kyazdani42/nvim-tree.lua',
      requires = {
        {'kyazdani42/nvim-web-devicons'}
      },
      opt = true
    } -- super fast file tree viewer
    use {
      'akinsho/nvim-bufferline.lua',
      commit = "7b9223ff",
      lock = true,
      requires = {
        {'kyazdani42/nvim-web-devicons'}
      }
    } -- snazzy bufferline
    use {'neovim/nvim-lspconfig', opt = true} -- builtin lsp config
    use {
      'mhartington/formatter.nvim',
      ft = {'lua', 'rust', 'javascript', 'typescript', 'html', 'css', 'svelte'},
      opt = true
    } -- formatter, experimenting
    use {
      'mattn/emmet-vim',
      cmd = 'EmmetInstall',
      opt = true
    } -- less typing for html code
    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        {'nvim-lua/popup.nvim'},
        {'nvim-lua/plenary.nvim'},
      }
    } -- extensible fuzzy finder
    use 'nvim-telescope/telescope-fzy-native.nvim' -- faster sorter for telescope
    use {'lewis6991/gitsigns.nvim', opt = true} -- show git stuff in signcolumn
    use {
      'rhysd/git-messenger.vim',
      cmd = 'GitMessenger',
      opt = true
    } -- sort of like git blame but in floating window
    use 'tpope/vim-surround' -- surround words with symbol
    use {
      'mhinz/vim-sayonara',
      cmd = 'Sayonara',
      opt = true
    }
    use 'ElPiloto/sidekick.nvim'
    -- better window and buffer management
  end

  return packer.startup(plugins)
end
