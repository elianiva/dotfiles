require("neo-tree").setup {
  use_libuv_file_watcher = true,
  filesystem = {
    window = {
      position = "left",
      width = 32,
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["o"] = "open",
        ["<C-x>"] = "open_split",
        ["<C-v>"] = "open_vsplit",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["I"] = "toggle_gitignore",
        ["R"] = "refresh",
        ["/"] = "filter_as_you_type",
        ["f"] = "filter_on_submit",
        ["<BS>"] = "clear_filter",
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
      },
    },
  },
}
