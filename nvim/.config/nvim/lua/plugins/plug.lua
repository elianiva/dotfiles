-- TODO: find out why some plugins doesn't apply its config using this method
local plug_directory = '~/.local/share/nvim/site/autoload/plug.vim'
local plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
local plugins_directory = '~/.local/share/nvim/plugged'

-- TODO: find a better way for this
if vim.fn.empty(vim.fn.glob(plug_directory)) == 1 then
  vim.cmd([[
     silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
     au VimEnter * PlugInstall --sync
  ]])
  -- vim.cmd(table.concat{
  --  'silent !curl -fLo',
  --  plug_directory,
  --  '--create-dirs',
  --  plug_url
  -- })
  -- vim.cmd('au VimEnter * PlugInstall --sync')
end

-- TODO: find better way instead of using escape ( \' )
-- define your plugins here
local plugins = {
  'gruvbox-community/gruvbox', -- nice colorscheme
  'jiangmiao/auto-pairs', -- autopairs brackets, braces, etc
  'neoclide/jsonc.vim', -- jsonc highlighting
  'wakatime/vim-wakatime', -- track usage time using wakatime
  'norcalli/nvim-colorizer.lua', -- colorize hex/rgb/hsl value
  'sheerun/vim-polyglot', -- various languages highlighting
  'evanleck/vim-svelte', -- svelte language support
  -- 'fatih/vim-go' -- golang highlighting
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
  'akinsho/nvim-bufferline.lua', -- bufferline
  'kyazdani42/nvim-tree.lua', -- file explorer
  'neovim/nvim-lspconfig', -- builtin lsp config
  'nvim-lua/completion-nvim', -- completion helper
  'steelsojka/completion-buffers', -- buffer source for completion
  'nvim-lua/diagnostic-nvim', -- diagnostic for nvim lsp
  -- {'neoclide/coc.nvim', '{\'branch\': \'release\'}'},  -- lsp stuff
  'tpope/vim-commentary', -- comment stuff easier
  'mattn/emmet-vim', -- less typing for html code
  'tpope/vim-surround', -- surround words with symbol
  -- 'nvim-lua/popup.nvim'
  -- 'nvim-lua/plenary.nvim'
  -- 'nvim-lua/telescope.nvim'
  {'junegunn/fzf', '{\'do\': { -> fzf#install() } }'}, -- fuzzy finder
  'junegunn/fzf.vim',
  'tpope/vim-fugitive', -- git helper
  -- 'airblade/vim-gitgutter', -- show git stuff in signcolumn
  'mhinz/vim-signify', -- show git stuff in signcolumn
}

local apply_plugins = function()
  vim.call('plug#begin', plugins_directory)

  for _, plugin in pairs(plugins) do
    if type(plugin) == 'table' then
      vim.cmd(string.format("Plug '%s', %s", plugin[1], plugin[2]))
    else
      vim.cmd(string.format("Plug '%s'", plugin))
    end
  end

  vim.call('plug#end')
end

-- apply dem sweet plugins
apply_plugins()
