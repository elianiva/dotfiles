-- Set some variables
vim.g.vim_tree_special_files = {
  "README.md",
  "LICENSE",
  "Makefile",
  "package.json",
  "package-lock.json",
}
vim.g.nvim_tree_ignore = {
  ".git",
  "node_modules",
  "__sapper__",
  ".routify",
  "dist",
  ".cache",
}
vim.g.nvim_tree_show_icons = {
  git = 0,
  folders = 1,
  files = 1,
}
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_auto_close = 0
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_follow = 0
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_group_empty = 0
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_highlight_opened_files = 0
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_root_folder_modifier = ":~"
vim.g.nvim_tree_side = "left"
vim.g.nvim_tree_tab_open = 0
vim.g.nvim_tree_width = 30

-- Mappings for nvimtree
local get_lua_cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
  { key = { "<CR>" },           cb = get_lua_cb "edit" },
  { key = { "o" },              cb = get_lua_cb "edit" },
  { key = { "<2-LeftMouse>" },  cb = get_lua_cb "edit" },
  { key = { "<2-RightMouse>" }, cb = get_lua_cb "cd" },
  { key = { "<C-]>" },          cb = get_lua_cb "cd" },
  { key = { "<C-[>" },          cb = get_lua_cb "dir_up" },
  { key = { "<C-v>" },          cb = get_lua_cb "vsplit" },
  { key = { "<C-x>" },          cb = get_lua_cb "split" },
  { key = { "<C-t>" },          cb = get_lua_cb "tabnew" },
  { key = { "<BS>" },           cb = get_lua_cb "close_node" },
  { key = { "<S-CR>" },         cb = get_lua_cb "close_node" },
  { key = { "<Tab>" },          cb = get_lua_cb "preview" },
  { key = { "I" },              cb = get_lua_cb "toggle_ignored" },
  { key = { "H" },              cb = get_lua_cb "toggle_dotfiles" },
  { key = { "R" },              cb = get_lua_cb "refresh" },
  { key = { "a" },              cb = get_lua_cb "create" },
  { key = { "d" },              cb = get_lua_cb "remove" },
  { key = { "r" },              cb = get_lua_cb "rename" },
  { key = { "<C-r>" },          cb = get_lua_cb "full_rename" },
  { key = { "x" },              cb = get_lua_cb "cut" },
  { key = { "c" },              cb = get_lua_cb "copy" },
  { key = { "p" },              cb = get_lua_cb "paste" },
  { key = { "[c" },             cb = get_lua_cb "prev_git_item" },
  { key = { "]c" },             cb = get_lua_cb "next_git_item" },
  { key = { "q" },              cb = get_lua_cb "close" },
}

-- default will show icon by default if no icon is provided
-- default shows no icon by default
vim.g.nvim_tree_icons = {
  default = "",
  symlink = "",

  git = {
    unstaged = "",
    staged = "",
    unmerged = "",
    renamed = "",
    untracked = "",
    deleted = "",
    ignored = "",
  },

  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  },
}
