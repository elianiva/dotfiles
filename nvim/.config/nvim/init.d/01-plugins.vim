" Install vim-plug if not exist already
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  au VimEnter * PlugInstall --sync | source '~/.config/nvim/init.vim'
endif

call plug#begin('~/.local/share/nvim/plugged')

" Colorscheme
" Plug 'elianiva/palenight.vim'
Plug 'gruvbox-community/gruvbox'

" Auto pairs brackets and other stuff
Plug 'jiangmiao/auto-pairs'

" Orgmode
" Plug 'jceb/vim-orgmode'
" Plug 'tpope/vim-speeddating'

" Tree sitter
" Plug 'nvim-treesitter/nvim-treesitter'

" Scratchpad
Plug 'metakirby5/codi.vim'

" JSONC filetype support
Plug 'neoclide/jsonc.vim'

" Gitlens as in vscode
" Plug 'APZelos/blamer.nvim'

" stats for wakatime
Plug 'wakatime/vim-wakatime'

" Homepage for nvim
" Plug 'mhinz/vim-startify'

" Colorizer for colours
Plug 'norcalli/nvim-colorizer.lua'

" Syntax support for various language
Plug 'sheerun/vim-polyglot'
" Plug 'evanleck/vim-svelte'
" Plug 'fatih/vim-go'
Plug 'uiiaoo/java-syntax.vim'
Plug 'euclidianAce/BetterLua.vim' " better lua syntax
Plug 'evanleck/vim-svelte' "Svelte stuff

" Indentation guide
Plug 'Yggdroot/indentline'

" Distraction free writing
Plug 'junegunn/goyo.vim', {'for': ['markdown', 'txt']}

" Table mode for easier table generation
Plug 'dhruvasagar/vim-table-mode', {'for': ['txt', 'markdown']}

" Smooth scrolling effect
Plug 'psliwka/vim-smoothie'

" Icons for terminal nvim
Plug 'kyazdani42/nvim-web-devicons'

" Bufferline
Plug 'akinsho/nvim-bufferline.lua'

" File explorer
Plug 'kyazdani42/nvim-tree.lua'

" Intellisense and LSP support
" Plug 'neovim/nvim-lspconfig'
" Plug 'nvim-lua/completion-nvim'
" Plug 'steelsojka/completion-buffers'
" Plug 'nvim-lua/diagnostic-nvim'
Plug 'neoclide/coc.nvim', {'branch' : 'release'}
Plug 'honza/vim-snippets'

" Comment block of code easily
Plug 'tpope/vim-commentary'

" Emmet for less typing on html code
Plug 'mattn/emmet-vim'

" Surround words with symbol
Plug 'tpope/vim-surround'

" Stupidly fast fuzzy search engine
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/telescope.nvim'

" Statusline
" Plug 'tjdevries/express_line.nvim'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()
