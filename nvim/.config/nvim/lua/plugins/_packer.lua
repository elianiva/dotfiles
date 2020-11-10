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

    use {
      'haorenW1025/completion-nvim',
      requires = {
        {'hrsh7th/vim-vsnip', opt = true},
        {'hrsh7th/vim-vsnip-integ', opt = true},
        {'steelsojka/completion-buffers', opt = true},
      },
      config = {'require [[plugins/_completion]]'}
    }

    use 'gruvbox-community/gruvbox' -- nice colorscheme
    -- use 'tjdevries/colorbuddy.nvim' -- colorscheme maker
    use 'cohama/lexima.vim' -- autopairs brackets, braces etc
    use {'neoclide/jsonc.vim', opt = true}-- jsonc highlighting
    use 'wakatime/vim-wakatime' -- track usage time using wakatime
    use 'norcalli/nvim-colorizer.lua' -- colorize hex/rgb/hsl value
    use {'pangloss/vim-javascript', ft = {'svelte'}}-- javascript highlights
    -- use 'sheerun/vim-polyglot' -- various syntax highlights
    use 'nvim-treesitter/nvim-treesitter' -- better syntax highlighting
    use {
      'nvim-treesitter/playground',
      cmd = 'TSHighlightCapturesUnderCursor'
    } -- playground for treesitter
    use {'leafOfTree/vim-svelte-plugin', opt = true } -- svelte language support
    -- use 'euclidianAce/BetterLua.vim' -- better lua highlights
    -- 'uiiaoo/java-syntax.vim' -- better java highlights
    use {'Yggdroot/indentline', opt = true}-- indentline guide
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
    use 'psliwka/vim-smoothie' -- smooth scroll
    use 'kyazdani42/nvim-web-devicons' -- smooth scroll
    use 'kyazdani42/nvim-tree.lua' -- file explorer
    use {
      'akinsho/nvim-bufferline.lua',
    } -- bufferline
    use 'neovim/nvim-lspconfig' -- builtin lsp config
    -- {'neoclide/coc.nvim' [[{'branch': 'release'}]]}, -- coc.nvim
    use 'lukas-reineke/format.nvim' -- formatter
    use 'nvim-lua/diagnostic-nvim' -- diagnostic for nvim lsp
    use 'tpope/vim-commentary' -- comment stuff easier
    use 'mattn/emmet-vim' -- less typing for html code
    use 'tpope/vim-surround' -- surround words with symbol
    use 'nvim-lua/popup.nvim' -- surround words with symbol
    use 'nvim-lua/plenary.nvim' -- surround words with symbol
    use 'nvim-lua/telescope.nvim' -- fuzzy finder
    use 'mhinz/vim-signify' -- show git stuff in signcolumn
  end

  local config = {
    display = {
      open_fn = function(name)
        -- Can only use plenary when we have our plugins.
        --  We can only get plenary when we don't have our plugins ;)
        local ok, float_win = pcall(function()
          return require('plenary.window.float').percentage_range_window(0.8, 0.8)
        end)

        if not ok then
          vim.cmd [[60vnew  [packer] ]]

          return vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
        end

        local bufnr = float_win.bufnr
        local win = float_win.win_id

        vim.api.nvim_buf_set_name(bufnr, name)
        vim.api.nvim_win_set_option(win, 'winblend', 10)

        return win, bufnr
      end
    },
  }

  return packer.startup(plugins, config)
end
