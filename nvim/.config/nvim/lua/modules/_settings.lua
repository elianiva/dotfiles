local cmd = vim.api.nvim_command

local apply_options = function(opts)
  for k, v in pairs(opts) do
    if v == true then
      cmd('set ' .. k)
    elseif v == false then
      cmd(string.format('set no%s', k))
    else
      cmd(string.format('set %s=%s', k, v))
    end
  end
end

local options = {
  -- Boolean value
  number = true, -- enable number
  relativenumber = true, -- enable relativenumber
  wrap = false, -- dont wrap lines
  hidden = true, -- keep hidden buffers
  backup = false, -- disable backup
  writebackup = false, -- disable backup
  swapfile = false, -- disable swapfile
  smarttab = true, -- make tab behaviour smarter
  expandtab = true, -- use spaces instead of tabs
  showmode = false, -- don't show mode
  smartcase = true, -- improve searching using '/'
  hlsearch = false, -- don't highlight matching search
  ignorecase = true, -- case insensitive on search
  autowrite = true, -- autowrite buffer when it's not focused
  autoindent = true, -- enable autoindent
  cursorline = true, -- enable cursorline
  splitbelow = true, -- split below instead of above
  splitright = true, -- split right instead of left
  smartindent = true, -- smarter indentation
  startofline = false, -- don't go to the start of the line when moving to another file
  termguicolors = true, -- truecolours for better experience
  lazyredraw = true, -- lazyredraw to make macro faster
  list = true, -- display listchars

  -- String value
  encoding = "UTF-8", -- set encoding
  mouse = "a", -- enable mouse support
  shortmess = "csa", -- disable some stuff on shortmess
  fillchars = "vert:┃", -- make vertical split sign better
  foldmethod = "marker", -- foldmethod using marker
  signcolumn = "yes", -- enable sign column all the time, 4 column
  backupcopy = "yes", -- fix weirdness for postcss
  completeopt = 'menuone,noinsert,noselect,longest', -- better completion
  inccommand = "split", -- incrementally show result of command
  listchars = "eol:↲,tab:»\\ ", -- set listchars

  -- Number value
  shiftwidth = 2, -- set indentation width
  tabstop = 2, -- tabsize
  laststatus = 2, -- always enable statusline
  scrolloff = 2, -- make scrolling better
  sidescroll = 2, -- make scrolling better
  sidescrolloff = 15, -- make scrolling better
  pumheight = 10, -- limit completion items
  re = 0, -- set regexp engine to auto
  synmaxcol = 300, -- set limit for syntax highlighting in a single line
  updatetime = 100, -- set faster update time
  colorcolumn = 80, -- 80 chars color column
  timeoutlen = 500 -- faster timeout wait time
  -- pumblend = 15, -- transparent completion menu
}

apply_options(options)
