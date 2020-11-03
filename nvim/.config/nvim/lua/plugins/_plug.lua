-- TODO: find out why some plugins doesn't apply its config using this method
local plug_directory = '~/.local/share/nvim/site/autoload/plug.vim'
local plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
local plugins_directory = '~/.local/share/nvim/plugged'
local fn = vim.fn
local cmd = vim.cmd
local call = vim.call

-- TODO: find a better way for this
if fn.empty(fn.glob(plug_directory)) == 1 then
  cmd([[
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    au VimEnter * PlugInstall --sync
  ]])
end

local plugins = {
  'gruvbox-community/gruvbox', -- nice colorscheme
  'tjdevries/colorbuddy.nvim', -- colorscheme maker
  'cohama/lexima.vim', -- autopairs brackets, braces, etc
  'neoclide/jsonc.vim', -- jsonc highlighting
  'wakatime/vim-wakatime', -- track usage time using wakatime
  'norcalli/nvim-colorizer.lua', -- colorize hex/rgb/hsl value
  'sheerun/vim-polyglot', -- various languages highlighting
  -- 'nvim-treesitter/nvim-treesitter', -- better syntax highlighting
  -- 'nvim-treesitter/playground', -- playground for treesitter
  'leafOfTree/vim-svelte-plugin', -- svelte language support
  'euclidianAce/BetterLua.vim', -- better lua highlights
  'uiiaoo/java-syntax.vim', -- better java highlights
  'Yggdroot/indentline', -- indentline guide
  {
    'junegunn/goyo.vim',
    [[{'for': ['markdown', 'txt']}]],
  }, -- zen mode
  {
    'dhruvasagar/vim-table-mode',
    [[{'for': ['txt', 'markdown']}]],
  }, -- table alignment
  'psliwka/vim-smoothie', -- smooth scroll
  'kyazdani42/nvim-web-devicons', -- fancy icons
  'kyazdani42/nvim-tree.lua', -- file explorer
  'akinsho/nvim-bufferline.lua', -- bufferline
  'neovim/nvim-lspconfig', -- builtin lsp config
  -- {'neoclide/coc.nvim', [[{'branch': 'release'}]]}, -- coc.nvim
  'lukas-reineke/format.nvim', -- formatter
  'nvim-lua/completion-nvim', -- completion helper
  'steelsojka/completion-buffers', -- buffer source for completion
  'nvim-lua/diagnostic-nvim', -- diagnostic for nvim lsp
  'tpope/vim-commentary', -- comment stuff easier
  'mattn/emmet-vim', -- less typing for html code
  'tpope/vim-surround', -- surround words with symbol
  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',
  'nvim-lua/telescope.nvim', -- fuzzy finder
  'mhinz/vim-signify', -- show git stuff in signcolumn
}

local apply_plugins = function()
  call('plug#begin', plugins_directory)

  for _, plugin in pairs(plugins) do
    if type(plugin) == 'table' then
      cmd(string.format("Plug '%s', %s", plugin[1], plugin[2]))
    else
      cmd(string.format("Plug '%s'", plugin))
    end
  end

  vim.call('plug#end')
end

-- apply dem sweet plugins
apply_plugins()
