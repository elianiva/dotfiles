local actions = require('telescope.actions')
local previewers = require('telescope.previewers')

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
        preview_width = 0.6,
      },
      vertical = {
        width_padding = 0.05,
        height_padding = 1,
        preview_height = 0.5,
      }
    },
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,

        ['<CR>'] = actions.select_default + actions.center,
        ['<C-v>'] = actions.select_vertical,
        ['<C-x>'] = actions.select_horizontal,
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
        ['<CR>'] = actions.select_default + actions.center,
        ['<C-v>'] = actions.select_vertical,
        ['<C-x>'] = actions.select_horizontal,
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
    },
    arecibo = {
      ["selected_engine"] = 'duckduckgo',
      ["url_open_command"] = 'xdg-open',
      ["show_http_headers"] = false,
      ["show_domain_icons"] = false,
    }
  },
}

require('telescope').load_extension('fzy_native') -- superfast sorter
require('telescope').load_extension('media_files') -- media preview
require('telescope').load_extension('frecency') -- frecency
require('telescope').load_extension('arecibo') -- websearch

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

local no_preview = function()
  return require('telescope.themes').get_dropdown({
    borderchars = {
      { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
      results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    },
    width = math.floor(vim.api.nvim_win_get_width(0) * 0.8),
    previewer = false
  })
end

M.arecibo = function()
  require("telescope").extensions.arecibo.websearch(no_preview())
end

M.frecency = function()
  require"telescope".extensions.frecency.frecency(no_preview())
end

M.buffer_fuzzy = function ()
  require"telescope.builtin".current_buffer_fuzzy_find(no_preview())
end

return M
