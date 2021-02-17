local actions = require('telescope.actions')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

local M = {}

require'telescope'.setup{
  defaults = {
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    scroll_strategy = 'cycle',
    selection_strategy = 'reset',
    layout_strategy = 'flex',
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
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
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,

        ['<CR>'] = actions.goto_file_selection_edit + actions.center,
        ['<C-v>'] = actions.goto_file_selection_vsplit,
        ['<C-x>'] = actions.goto_file_selection_split,
        ['<C-t>'] = actions.select_tab,

        ['<C-c>'] = actions.close,
        ['<Esc>'] = actions.close,

        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down,
        ['<C-q>'] = actions.send_to_qflist,
        ['<Tab>'] = actions.toggle_selection,
        -- ["<C-w>l"] = actions.preview_switch_window_right,
      },
      n = {
        ['<CR>'] = actions.goto_file_selection_edit + actions.center,
        ['<C-v>'] = actions.goto_file_selection_vsplit,
        ['<C-x>'] = actions.goto_file_selection_split,
        ['<C-t>'] = actions.select_tab,
        ['<Esc>'] = actions.close,

        ['j'] = actions.move_selection_next,
        ['k'] = actions.move_selection_previous,

        ['<C-u>'] = actions.preview_scrolling_up,
        ['<C-d>'] = actions.preview_scrolling_down,
        ['<C-q>'] = actions.send_to_qflist,
        ['<Tab>'] = actions.toggle_selection,
        -- ["<C-w>l"] = actions.preview_switch_window_right,
      }
    },
  },
  extensions = {
    media_files = {
      filetypes = {"png", "webp", "jpg", "jpeg", "pdf", "mkv"},
      find_cmd = "rg"
    },
    frecency = {
      show_scores = false,
      show_unindexed = true,
      ignore_patterns = {"*.git/*", "*/tmp/*"},
       workspaces = {
        ["nvim"] = "/home/elianiva/.config/nvim",
        ["awesome"] = "/home/elianiva/.config/awesome",
        ["alacritty"] = "/home/elianiva/.config/alacritty",
        ["scratch"] = "/home/elianiva/codes/scratch",
      }
    }
  },
}

require('telescope').load_extension('fzy_native') -- superfast sorter
require('telescope').load_extension('media_files') -- media preview
require('telescope').load_extension('frecency') -- frecency
require('telescope').load_extension('cheat') -- frecency

M.grep_prompt = function()
  require'telescope.builtin'.grep_string{
    shorten_path = true,
    search = vim.fn.input("Grep String > ")
  }
end

M.files = function()
  require'telescope.builtin'.find_files{
    file_ignore_patterns = {"%.png", "%.jpg", "%.webp"},
  }
end

M.colours = function(opts)
  opts = opts or {}
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
  P(vimgrep_arguments)
  local search_dirs = opts.search_dirs
  local search = opts.search or vim.fn.expand("<cword>")
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd)

  if search_dirs then
    for i, path in ipairs(search_dirs) do
      search_dirs[i] = vim.fn.expand(path)
    end
  end

  pickers.new(opts, {
    prompt_title = 'Live Grep',
    finder = finders.new_oneshot_job(
      vim.tbl_flatten {
        vimgrep_arguments,
        "#[a-fA-F0-9]{6}",
        search,
        search_dirs or "."
      },
      opts
    ),
    previewer = false,
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
