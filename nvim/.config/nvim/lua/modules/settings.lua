function setOptions(options)
  for k, v in pairs(options) do
    if v == true then
      vim.api.nvim_command('set ' .. k)
    elseif v == false then
      vim.api.nvim_command('set no' .. k)
    else
      vim.api.nvim_command('set ' .. k .. '=' .. v)
    end
  end
end

function core_options()
  local options = {
    encoding = "UTF-8", -- set encoding
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
    cursorline = true, -- enable cursorline
    splitbelow = true, -- split below instead of above
    splitright = true, -- split right instead of left
    smartindent = true, -- smarter indentation
    startofline = false, -- don't go to the start of the line when moving to another file
    termguicolors = true, -- truecolours for better experience

    mouse = "a", -- enable mouse support
    shortmess = "cs", -- disable some stuff on shortmess
    fillchars = "vert:┃", -- make vertical split sign better
    foldmethod = "marker", -- foldmethod using marker
    shiftwidth = 2, -- set indentation width
    tabstop = 2, -- tabsize
    laststatus = 2, -- enable statusline
    scrolloff = 3, -- make scrolling better
    sidescroll = 3,
    sidescroll = 3,
    pumheight = 16,
    sidescrolloff = 15,
    re = 0, -- set regexp engine to auto
    synmaxcol = 300, -- set limit for syntax highlighting in a single line
    updatetime = 100, -- set update time
    signcolumn = "yes", -- enable sign column all the time
    backupcopy= "yes", -- fix weirdness for postcss
    completeopt='menuone,noinsert,noselect' -- better completion
  }

  setOptions(options)
end

core_options()
