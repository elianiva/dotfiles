local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
  -- TODO: Maybe handle windows better?
  if vim.fn.input("Download Packer? (y for yes)") ~= "y" then
    return
  end

  local directory = string.format(
    '%s/site/pack/packer/opt/',
    vim.fn.stdpath('data')
  )

  vim.fn.mkdir(directory, 'p')

  local out = vim.fn.system(string.format(
    'git clone %s %s',
    'https://github.com/wbthomason/packer.nvim',
    directory .. '/packer.nvim'
  ))

  print(out)
  print("Downloading packer.nvim...")

  return
end

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
    use 'neoclide/jsonc.vim'-- jsonc highlighting
    use 'wakatime/vim-wakatime' -- track usage time using wakatime
    use 'norcalli/nvim-colorizer.lua' -- colorize hex/rgb/hsl value
    use {
      'leafOfTree/vim-svelte-plugin',
      requires = {
        {'pangloss/vim-javascript', ft = { 'svelte' }},
      }
    }-- svelte language support
    use 'nvim-treesitter/nvim-treesitter' -- better syntax highlighting
    use 'nvim-treesitter/playground' -- playground for treesitter
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
      }
    }
    use {
      'akinsho/nvim-bufferline.lua',
      requires = {
        {'kyazdani42/nvim-web-devicons'}
      }
    } -- bufferline
    use 'neovim/nvim-lspconfig' -- builtin lsp config
    use 'mhartington/formatter.nvim' -- formatter, experimenting
    use 'tpope/vim-commentary' -- comment stuff easier
    use 'mattn/emmet-vim' -- less typing for html code
    use 'tpope/vim-surround' -- surround words with symbol
    use {
      'nvim-telescope/telescope.nvim',
      -- 'Conni2459/telescope.nvim',
      -- branch = 'vim_buffers_everywhere',
      requires = {
        {'nvim-lua/popup.nvim'},
        {'nvim-lua/plenary.nvim'},
      }
    } -- extensible fuzzy finder
    use 'nvim-telescope/telescope-fzy-native.nvim' -- faster sorter for telescope
    use 'lewis6991/gitsigns.nvim' -- show git stuff in signcolumn
    use 'rhysd/git-messenger.vim' -- sort of like git blame but in floating window
  end

  return packer.startup(plugins)
end
