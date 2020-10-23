vim.cmd [[packadd packer.nvim]]
vim._update_package_paths()

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}
  use 'gruvbox-community/gruvbox' -- nice colorscheme
  -- 'jiangmiao/auto-pairs', -- autopairs brackets, braces, etc
  use 'cohama/lexima.vim' -- autopairs brackets, braces, etc
  -- use 'hrsh7th/nvim-compe' -- completion
  use 'neoclide/jsonc.vim' -- jsonc highlighting
  use 'wakatime/vim-wakatime' -- track usage time using wakatime
  use 'norcalli/nvim-colorizer.lua' -- colorize hex/rgb/hsl value
  use 'sheerun/vim-polyglot' -- various languages highlighting
  use 'evanleck/vim-svelte' -- svelte language support
  -- 'fatih/vim-go' -- golang highlighting
  use 'euclidianAce/BetterLua.vim' -- better lua highlighting
  use 'Yggdroot/indentline' -- indentline guide
  use {'junegunn/goyo.vim', {ft = {'markdown', 'txt'} }} -- zen mode
  use {'dhruvasagar/vim-table-mode', {ft = {'txt', 'markdown'}}} -- table alignment
  use 'psliwka/vim-smoothie' -- smooth scroll
  use 'kyazdani42/nvim-web-devicons' -- fancy icons
  use 'kyazdani42/nvim-tree.lua' -- file explorer
  use 'akinsho/nvim-bufferline.lua' -- bufferline
  use 'neovim/nvim-lspconfig' -- builtin lsp config
  use 'mhartington/formatter.nvim' -- formatter
  use 'nvim-lua/completion-nvim' -- completion helper
  use 'steelsojka/completion-buffers' -- buffer source for completion
  use 'nvim-lua/diagnostic-nvim' -- diagnostic for nvim lsp
  -- {'neoclide/coc.nvim', '{\'branch\': \'release\'}'},  -- lsp stuff
  use 'tpope/vim-commentary' -- comment stuff easier
  use 'mattn/emmet-vim' -- less typing for html code
  use 'tpope/vim-surround' -- surround words with symbol
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/telescope.nvim' -- fuzzy finder
  -- use {'junegunn/fzf', { run = vim.call('fzf#install') }} -- fuzzy finder
  use 'junegunn/fzf.vim'
  use 'tpope/vim-fugitive' -- git helper
  -- 'airblade/vim-gitgutter', -- show git stuff in signcolumn
  use 'mhinz/vim-signify' -- show git stuff in signcolumn
end)
