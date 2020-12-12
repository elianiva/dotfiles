local remap = vim.api.nvim_set_keymap

remap('n', '<C-m>', '<CMD>call SideKickNoReload()<CR>', { noremap = true })

vim.g.sidekick_update_on_buf_write = 1

-- List of which definition types to display:
-- Example: 'function' tells sidekick to display any node found in a ts 'locals' query
-- that is captured in `queries/$LANG/locals.scm` as '@definition.function'.
vim.g.sidekick_printable_def_types = {
  'function', 'class', 'type', 'module', 'parameter', 'method', 'field'
}

-- Mapping from definition type to the icon displayed for that type in the outline window.
vim.g.sidekick_def_type_icons = {
    class = "\u{f0e8}",
    type = "\u{f0e8}",
    ['function'] = "\u{f794}",
    module = "\u{f7fe}",
    arc_component = "\u{f6fe}",
    sweep = "\u{f7fd}",
    parameter = "•",
    var = "v",
    method = "\u{f794}",
    field = "\u{f6de}",
}

-- Indicates which definition types should have their line number displayed in the outline window.
vim.g.sidekick_line_num_def_types = {
   class = 1,
   type = 1,
   ['function'] = 1,
   module = 1,
   method = 1,
}

-- What to display between definition and line number
vim.g.sidekick_line_num_separator = " "

-- What to display to the left and right of the line number
vim.g.sidekick_line_num_left = "\u{e0b2}"
vim.g.sidekick_line_num_right = "\u{e0b0}"

-- What to display before outer vs inner definitions
vim.g.sidekick_inner_node_icon = "\u{251c}\u{2500}\u{25B8}"
vim.g.sidekick_outer_node_icon = "\u{2570}\u{2500}\u{25B8}"

-- What to display to left and right of def_type_icon
vim.g.sidekick_left_bracket = "\u{27ea}"
vim.g.sidekick_right_bracket = "\u{27eb}"
