-- Set some variables
vim.g.lua_tree_side = 'left'
vim.g.lua_tree_width = 30
vim.g.lua_tree_ignore = {
  '.git', 'node_modules', '__sapper__', '.routify', 'dist', '.cache'
}
vim.g.lua_tree_auto_open = 0
vim.g.lua_tree_auto_close = 1
vim.g.lua_tree_follow = 1
vim.g.lua_tree_indent_markers = 1
vim.g.lua_tree_hide_dotfiles = 1
vim.g.lua_tree_git_hl = 1
vim.g.lua_tree_root_folder_modifier = ':~'
vim.g.lua_tree_tab_open = 0
vim.g.lua_tree_show_icons = {git = 0, folders = 1, files = 1}

-- Mappings for luatree
vim.g.lua_tree_bindings = {
  edit = {'<CR>', 'o'},
  edit_vsplit = '<C-v>',
  edit_split = '<C-x>',
  edit_tab = '<C-t>',
  toggle_ignored = 'I',
  toggle_dotfiles = 'H',
  refresh = 'R',
  preview = '<Tab>',
  cd = 'cd',
  create = 'a',
  remove = 'd',
  rename = 'r',
  cut = 'x',
  copy = 'c',
  paste = 'p',
  prev_git_item = '[c',
  next_git_item = ']c'
}

-- default will show icon by default if no icon is provided
-- default shows no icon by default
vim.g.lua_tree_icons = {
  default = '',
  symlink = '',

  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★"
  },

  folder = {default = "", open = " "}
}
