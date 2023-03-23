vim.g.neo_tree_remove_legacy_commands = 1

local global_commands = {
  parent_or_close = function(state)
    local node = state.tree:get_node()
    if (node.type == "directory" or node:has_children()) and node:is_expanded() then
      state.commands.toggle_node(state)
    else
      require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
    end
  end,
  child_or_open = function(state)
    local node = state.tree:get_node()
    if node.type == "directory" or node:has_children() then
      if not node:is_expanded() then -- if unexpanded, expand
        state.commands.toggle_node(state)
      else -- if expanded and has children, seleect the next child
        require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
      end
    else -- if not a directory just open it
      state.commands.open(state)
    end
  end,
  copy_selector = function(state)
    local node = state.tree:get_node()
    local filepath = node:get_id()
    local filename = node.name
    local modify = vim.fn.fnamemodify

    local results = {
      e = { val = modify(filename, ":e"), msg = "Extension only" },
      f = { val = filename, msg = "Filename" },
      F = { val = modify(filename, ":r"), msg = "Filename w/o extension" },
      h = { val = modify(filepath, ":~"), msg = "Path relative to Home" },
      p = { val = modify(filepath, ":."), msg = "Path relative to CWD" },
      P = { val = filepath, msg = "Absolute path" },
    }

    local messages = {
      { "\nChoose to copy to clipboard:\n", "Normal" },
    }
    for i, result in pairs(results) do
      if result.val and result.val ~= "" then
        vim.list_extend(messages, {
          { ("%s."):format(i), "Identifier" },
          { (" %s: "):format(result.msg) },
          { result.val, "String" },
          { "\n" },
        })
      end
    end
    vim.api.nvim_echo(messages, false, {})
    local result = results[vim.fn.getcharstr()]
    if result and result.val and result.val ~= "" then
      vim.notify("Copied: " .. result.val)
      vim.fn.setreg("+", result.val)
    end
  end,
}

require("neo-tree").setup {
  auto_clean_after_session_restore = true,
  close_if_last_window = true,
  source_selector = {
    winbar = true,
    content_layout = "center",
  },
  default_component_configs = {
    indent = { padding = 0, indent_size = 1 },
  },
  window = {
    position = "right",
    width = 40,
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
  filesystem = {
    follow_current_file = true,
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,
    commands = global_commands,
  },
  buffers = { commands = global_commands },
  git_status = { commands = global_commands },
  diagnostics = { commands = global_commands },
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function(_) vim.opt_local.signcolumn = "auto" end,
    },
  },
}
