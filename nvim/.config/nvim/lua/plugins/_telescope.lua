local telescope_actions = require('telescope.actions')

require'telescope'.setup{
  defaults = {
    winblend = 8,
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    -- prompt_position = "top",
    -- sorting_strategy = "ascending",
    default_icon = true,
    default_mappings = {
      i = {
        ['<C-j>'] = telescope_actions.move_selection_next,
        ['<C-k>'] = telescope_actions.move_selection_previous,
        ['<C-b>'] = telescope_actions.preview_scrolling_up,
        ['<C-f>'] = telescope_actions.preview_scrolling_down,
        ['<CR>']  = telescope_actions.goto_file_selection_edit,

        ['<C-v>'] = telescope_actions.goto_file_selection_vsplit,
        ['<C-x>'] = telescope_actions.goto_file_selection_split,
        ['<C-t>'] = telescope_actions.goto_file_selection_tabedit,
        ['<C-c>'] = telescope_actions.close,
        ['<ESC>'] = telescope_actions.close,

        ['<C-u>'] = telescope_actions.preview_scrolling_up,
        ['<C-d>'] = telescope_actions.preview_scrolling_down,
      },
      n = {
        ['<CR>']  = telescope_actions.goto_file_selection_edit,
        ['<C-v>'] = telescope_actions.goto_file_selection_vsplit,
        ['<C-x>'] = telescope_actions.goto_file_selection_split,
        ['<C-t>'] = telescope_actions.goto_file_selection_tabedit,
        ['<ESC>'] = telescope_actions.close,

        ["j"] = telescope_actions.move_selection_next,
        ["k"] = telescope_actions.move_selection_previous,

        ['<C-u>'] = telescope_actions.preview_scrolling_up,
        ['<C-d>'] = telescope_actions.preview_scrolling_down,
      },
    },
  }
}
