# My Neovim Config

This neovim config is (almost) all in lua. Moar details soon once I finished making my website.

## Preview
![Preview](preview.png)

> Old preview because I can't be bothered to take the new one, just wait til I finish my website if you want to see it, or try it yourself :)

## Plugins
> Yeah, can't be bothered to list them here so I just took it from my config
```lua
local plugins = {
  'gruvbox-community/gruvbox', -- nice colorscheme
  'cohama/lexima.vim', -- autopairs brackets, braces, etc
  'neoclide/jsonc.vim', -- jsonc highlighting
  'wakatime/vim-wakatime', -- track usage time using wakatime
  'norcalli/nvim-colorizer.lua', -- colorize hex/rgb/hsl value
  'sheerun/vim-polyglot', -- various languages highlighting
  'leafOfTree/vim-svelte-plugin', -- svelte language support
  'euclidianAce/BetterLua.vim', -- better lua highlighting
  'Yggdroot/indentline', -- indentline guide
  {
    'junegunn/goyo.vim',
    '{\'for\': [\'markdown\', \'txt\']}'
  }, -- zen mode
  {
    'dhruvasagar/vim-table-mode',
    '{\'for\': [\'txt\', \'markdown\']}'
  }, -- table alignment
  'psliwka/vim-smoothie', -- smooth scroll
  'kyazdani42/nvim-web-devicons', -- fancy icons
  'kyazdani42/nvim-tree.lua', -- file explorer
  'akinsho/nvim-bufferline.lua', -- bufferline
  'neovim/nvim-lspconfig', -- builtin lsp config
  'tjdevries/nlua.nvim', -- better lua development experience
  'mhartington/formatter.nvim', -- formatter
  'nvim-lua/completion-nvim', -- completion helper
  'steelsojka/completion-buffers', -- buffer source for completion
  'nvim-lua/diagnostic-nvim', -- diagnostic for nvim lsp
  'tpope/vim-commentary', -- comment stuff easier
  'mattn/emmet-vim', -- less typing for html code
  'tpope/vim-surround', -- surround words with symbol
  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'nvim-lua/telescope.nvim', -- fuzzy finder
  'tpope/vim-fugitive', -- git helper
  'mhinz/vim-signify', -- show git stuff in signcolumn
}
```
