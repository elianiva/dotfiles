local o = vim.opt

-- o.number         = true -- enable number
-- o.relativenumber = true -- enable relativenumber
o.undofile       = true -- persistent undo
o.backup         = false -- disable backup
o.cursorline     = true -- enable cursorline
o.expandtab      = true -- use spaces instead of tabs
o.autowrite      = true -- autowrite buffer when it's not focused
o.hidden         = true -- keep hidden buffers
o.hlsearch       = true -- don't highlight matching search
o.ignorecase     = true -- case insensitive on search..
o.smartcase      = true -- ..unless there's a capital
o.equalalways    = true -- make window size always equal
o.lazyredraw     = true -- lazyredraw to make macro faster
o.list           = true -- display listchars
o.showmode       = false -- don't show mode
o.autoindent     = true -- enable autoindent
o.smartindent    = true -- smarter indentation
o.smarttab       = true -- make tab behaviour smarter
o.splitbelow     = true -- split below instead of above
o.splitright     = true -- split right instead of left
o.startofline    = false -- don't go to the start of the line when moving to another file
o.swapfile       = false -- disable swapfile
o.termguicolors  = true -- truecolours for better experience
o.wrap           = false -- dont wrap lines
o.writebackup    = false -- disable backup
o.swapfile       = false -- disable swap
o.backupcopy     = "yes" -- fix weirdness for stuff that replaces the entire file when hot reloading
o.completeopt    = {
  "menu",
  "menuone",
  "noselect",
  "noinsert",
} -- better completion
o.encoding       = "UTF-8" -- set encoding
o.fillchars      = {
  vert = "│",
  eob = " ",
  fold = " ",
  diff = " ",
} -- make vertical split sign better
o.foldmethod     = "manual"
o.foldopen       = {
  "percent",
  "search",
} -- don't open fold if I don't tell it to do so
-- o.foldexpr       = "nvim_treesitter#foldexpr()"
-- o.foldlevel      = 0 -- don't fold anything if I don't tell it to do so
-- o.foldnestmax    = 1 -- only allow 1 nested folds it can be confusing if I have too many
-- o.foldcolumn     = "1" -- enable fold column for better visualisation
o.inccommand     = "split" -- incrementally show result of command
o.listchars      = {
  eol = "↲",
  tab= "» ",
} -- set listchars
o.mouse          = "n" -- enable mouse support in normal mode
o.shortmess      = "csa" -- disable some stuff on shortmess
o.signcolumn     = "yes" -- enable sign column all the time 4 column
o.shell          = "/usr/bin/bash" -- use bash instead of zsh
-- o.colorcolumn    = { "80" } -- 80 chars color column
o.laststatus     = 2 -- always enable statusline
o.pumheight      = 10 -- limit completion items
o.re             = 0 -- set regexp engine to auto
o.scrolloff      = 2 -- make scrolling better
o.sidescroll     = 2 -- make scrolling better
o.shiftwidth     = 2 -- set indentation width
o.sidescrolloff  = 15 -- make scrolling better
o.tabstop        = 2 -- tabsize
o.timeoutlen     = 400 -- faster timeout wait time
o.updatetime     = 1000 -- set faster update time
o.joinspaces     = false

-- stolen from tjdevries
o.formatoptions = o.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore
