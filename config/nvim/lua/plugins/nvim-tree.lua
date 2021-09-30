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
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_gitignore = 1
vim.g.nvim_tree_group_empty = 0
vim.g.nvim_tree_hide_dotfiles = 1
vim.g.nvim_tree_highlight_opened_files = 0
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_root_folder_modifier = ":~"

-- Mappings for nvimtree
local tree_cb = require("nvim-tree.config").nvim_tree_callback
local mapping_list = {
  { key = "<CR>", cb = tree_cb "edit" },
  { key = "o", cb = tree_cb "edit" },
  { key = "<2-LeftMouse>", cb = tree_cb "edit" },
  { key = "<2-RightMouse>", cb = tree_cb "cd" },
  { key = "<C-]>", cb = tree_cb "cd" },
  { key = "<C-[>", cb = tree_cb "dir_up" },
  { key = "<C-v>", cb = tree_cb "vsplit" },
  { key = "<C-x>", cb = tree_cb "split" },
  { key = "<C-t>", cb = tree_cb "tabnew" },
  { key = "<BS>", cb = tree_cb "close_node" },
  { key = "<S-CR>", cb = tree_cb "close_node" },
  { key = "<Tab>", cb = tree_cb "preview" },
  { key = "I", cb = tree_cb "toggle_ignored" },
  { key = "H", cb = tree_cb "toggle_dotfiles" },
  { key = "R", cb = tree_cb "refresh" },
  { key = "a", cb = tree_cb "create" },
  { key = "d", cb = tree_cb "remove" },
  { key = "r", cb = tree_cb "rename" },
  { key = "<C-r>", cb = tree_cb "full_rename" },
  { key = "x", cb = tree_cb "cut" },
  { key = "c", cb = tree_cb "copy" },
  { key = "p", cb = tree_cb "paste" },
  { key = "[c", cb = tree_cb "prev_git_item" },
  { key = "]c", cb = tree_cb "next_git_item" },
  { key = "q", cb = tree_cb "close" },
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

require("nvim-tree").setup {
  auto_close = false,
  disable_netrw = true,
  hijack_netrw = true,
  open_on_tab = false,

  update_focused_file = {
    enable = false,
  },

  view = {
    width = 30,
    side = "left",
    auto_resize = false,
    mappings = {
      list = mapping_list,
    },
  },
}
