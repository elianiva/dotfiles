local actions = require('telescope.actions')

local M = {}

require'telescope'.setup{
  defaults = {
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    scroll_strategy = 'cycle',
    selection_strategy = 'reset',
    layout_strategy = 'flex',
    layout_defaults = {
      horizontal = {
        width_padding = 0.1,
        height_padding = 0.1,
        preview_width = 0.6
      },
      vertical = {
        width_padding = 0.05,
        height_padding = 1,
        preview_height = 0.5
      }
    },
    default_mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<CR>'] = actions.goto_file_selection_edit,

        ['<C-v>'] = actions.goto_file_selection_vsplit,
        ['<C-x>'] = actions.goto_file_selection_split,
        ['<C-t>'] = actions.goto_file_selection_tabedit,
        ['<C-c>'] = actions.close,
        ['<Esc>'] = actions.close,

        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down
      },
      n = {
        ['<CR>'] = actions.goto_file_selection_edit,
        ['<C-v>'] = actions.goto_file_selection_vsplit,
        ['<C-x>'] = actions.goto_file_selection_split,
        ['<C-t>'] = actions.goto_file_selection_tabedit,
        ['<Esc>'] = actions.close,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,

        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down
      }
    }
  }
}

-- depends on `nvim-telescope/telescope-fzy-native.nvim`
vim.cmd[[packadd telescope-fzy-native.nvim]]
require('telescope').load_extension('fzy_native') -- superfast sorter

M.grep_prompt = function()
  require'telescope.builtin'.grep_string{
    shorten_path = true,
    search = vim.fn.input("Grep String > ")
  }
end

return M
