-- require("modules._opts")

local apply_options = function(opts)
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end

local options = {
  autoindent     = true, -- enable autoindent
  backup         = false, -- disable backup
  cursorline     = true, -- enable cursorline
  expandtab      = true, -- use spaces instead of tabs
  autowrite      = true, -- autowrite buffer when it's not focused
  hidden         = true, -- keep hidden buffers
  hlsearch       = true, -- don't highlight matching search
  ignorecase     = true, -- case insensitive on search
  lazyredraw     = true, -- lazyredraw to make macro faster
  list           = true, -- display listchars
  -- number         = true, -- enable number
  -- relativenumber = true, -- enable relativenumber
  showmode       = false, -- don't show mode
  smartcase      = true, -- improve searching using '/'
  smartindent    = true, -- smarter indentation
  smarttab       = true, -- make tab behaviour smarter
  splitbelow     = true, -- split below instead of above
  splitright     = true, -- split right instead of left
  startofline    = false, -- don't go to the start of the line when moving to another file
  swapfile       = false, -- disable swapfile
  termguicolors  = true, -- truecolours for better experience
  wrap           = false, -- dont wrap lines
  writebackup    = false, -- disable backup
  backupcopy     = "yes", -- fix weirdness for stuff that replaces the entire file when hot reloading
  completeopt    = { "menu", "menuone", "noselect", "noinsert" }, -- better completion
  encoding       = "UTF-8", -- set encoding
  fillchars      = {
    vert = "│",
    eob = " ",
    fold = " ",
    diff = " ",
  }, -- make vertical split sign better
  foldmethod     = "marker",
  -- foldexpr       = "nvim_treesitter#foldexpr()",
  -- foldlevel      = 0, -- don't fold anything if I don't tell it to do so
  -- foldnestmax    = 1, -- only allow 1 nested folds, it can be confusing if I have too many
  foldopen       = {"percent", "search"}, -- don't open fold if I don't tell it to do so
  -- foldcolumn     = "1", -- enable fold column for better visualisation
  inccommand     = "split", -- incrementally show result of command
  listchars      = { eol = "↲", tab= "» " }, -- set listchars
  mouse          = "a", -- enable mouse support
  shortmess      = "csa", -- disable some stuff on shortmess
  signcolumn     = "yes", -- enable sign column all the time, 4 column
  shell          = "/usr/bin/bash", -- use bash instead of zsh
  colorcolumn    = { "80" }, -- 80 chars color column
  laststatus     = 2, -- always enable statusline
  pumheight      = 10, -- limit completion items
  re             = 0, -- set regexp engine to auto
  scrolloff      = 2, -- make scrolling better
  sidescroll     = 2, -- make scrolling better
  shiftwidth     = 2, -- set indentation width
  sidescrolloff  = 15, -- make scrolling better
  tabstop        = 2, -- tabsize
  timeoutlen     = 400, -- faster timeout wait time
  updatetime     = 100, -- set faster update time
}

apply_options(options)
