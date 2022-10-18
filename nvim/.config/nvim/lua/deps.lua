vim.cmd [[packadd packer.nvim]]

return require("packer").startup {
  {
    { "wbthomason/packer.nvim", opt = true } ,
    "gpanders/editorconfig.nvim" ,
    "AndrewRadev/splitjoin.vim" ,
    "machakann/vim-sandwich" ,
    "tweekmonster/startuptime.vim" ,
    "elianiva/gitgud.nvim" ,

    "Mofiqul/vscode.nvim",

    "feline-nvim/feline.nvim",

    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",

    "numToStr/Comment.nvim",
    "JoosepAlviste/nvim-ts-context-commentstring",

    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-lua/popup.nvim",
    "kyazdani42/nvim-web-devicons",
    "tami5/sqlite.lua",
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    "nvim-telescope/telescope-ui-select.nvim",

    -- requires plenary.nvim
    "ruifm/gitlinker.nvim",

    "https://gitlab.com/yorickpeterse/nvim-pqf",

    "junegunn/vim-easy-align",

    "mhinz/vim-sayonara",

    { "nvim-neo-tree/neo-tree.nvim", branch = "v2.x" },
    "MunifTanjim/nui.nvim",

    "hrsh7th/nvim-cmp",
    -- "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",

    -- requires plenary.nvim
    "lewis6991/gitsigns.nvim",

    -- requires kyazdani42/nvim-web-devicons
    "akinsho/nvim-bufferline.lua",

    "windwp/nvim-autopairs",

    -- "neovim/nvim-lspconfig",
    -- "jose-elias-alvarez/null-ls.nvim",
    -- "jose-elias-alvarez/nvim-lsp-ts-utils",
    -- "simrat39/rust-tools.nvim",

    -- "mfussenegger/nvim-dap",
    -- "rcarriga/nvim-dap-ui",
    -- "leoluz/nvim-dap-go",

    "phaazon/hop.nvim",

    -- "folke/zen-mode.nvim",

    "andymass/vim-matchup",

    -- "vim-test/vim-test",

    "norcalli/nvim-colorizer.lua",
  }
}
