local actions = require("telescope.actions")
local previewers = require("telescope.previewers")

local M = {}

local ok, telescope = pcall(require, "telescope")

telescope.setup({
  defaults = {
    file_previewer     = previewers.vim_buffer_cat.new,
    grep_previewer     = previewers.vim_buffer_vimgrep.new,
    qflist_previewer   = previewers.vim_buffer_qflist.new,
    scroll_strategy    = "cycle",
    selection_strategy = "reset",
    layout_strategy    = "flex",
    borderchars        = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_defaults = {
      horizontal = {
        width_padding  = 0.1,
        height_padding = 0.1,
        preview_width  = 0.6,
      },
      vertical = {
        width_padding  = 0.05,
        height_padding = 1,
        preview_height = 0.5,
      },
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<CR>"]  = actions.select_default + actions.center,
        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-t>"] = actions.select_tab,

        ["<C-c>"] = actions.close,
        ["<Esc>"] = actions.close,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        -- ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        -- ["<A-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
        ["<Tab>"] = actions.toggle_selection,
        -- ['<C-s>'] = actions.open_selected_files,
        -- ['<C-a>'] = actions.cycle_previewers_prev,
        -- ['<C-w>l'] = actions.preview_switch_window_right,
      },
      n = {
        ["<CR>"]  = actions.select_default + actions.center,
        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-t>"] = actions.select_tab,
        ["<Esc>"] = actions.close,

        ["j"]     = actions.move_selection_next,
        ["k"]     = actions.move_selection_previous,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        ["<C-q>"] = actions.send_to_qflist,
        ["<Tab>"] = actions.toggle_selection,
        -- ["<C-w>l"] = actions.preview_switch_window_right,
      },
    },
  },
  extensions = {
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg", "pdf", "mkv" },
      find_cmd  = "rg",
    },
    frecency = {
      show_scores     = false,
      show_unindexed  = true,
      ignore_patterns = { "*.git/*", "*/tmp/*" },
      workspaces = {
        ["nvim"]      = "/home/elianiva/.config/nvim",
        ["awesome"]   = "/home/elianiva/.config/awesome",
        ["alacritty"] = "/home/elianiva/.config/alacritty",
        ["scratch"]   = "/home/elianiva/codes/scratch",
      },
    },
    arecibo = {
      ["selected_engine"]   = "duckduckgo",
      ["url_open_command"]  = "xdg-open",
      ["show_http_headers"] = false,
      ["show_domain_icons"] = false,
    },
  },
})

pcall(require("telescope").load_extension, "fzy_native") -- superfast sorter
pcall(require("telescope").load_extension, "media_files") -- media preview
pcall(require("telescope").load_extension, "frecency") -- frecency
pcall(require("telescope").load_extension, "arecibo") -- websearch

M.grep_prompt = function()
  require("telescope.builtin").grep_string({
    shorten_path = true,
    search       = vim.fn.input("Grep String > "),
  })
end

M.files = function()
  require("telescope.builtin").find_files({
    file_ignore_patterns = { "%.png", "%.jpg", "%.webp" },
  })
end

local no_preview = function()
  return require("telescope.themes").get_dropdown({
    borderchars = {
      { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      prompt  = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
    width = 0.8,
    previewer = false,
  })
end

M.arecibo = function()
  require("telescope").extensions.arecibo.websearch(no_preview())
end

M.frecency = function()
  require("telescope").extensions.frecency.frecency(no_preview())
end

M.buffer_fuzzy = function()
  require("telescope.builtin").current_buffer_fuzzy_find(no_preview())
end

M.code_actions = function()
  require("telescope.builtin").lsp_code_actions(no_preview())
end

local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local pickers = require("telescope.pickers")
require("jdtls.ui").pick_one_async = function(results, _, label_fn, cb)
  local opts = no_preview()
  pickers.new(opts, {
    prompt_title = "LSP Code Actions",
    finder = finders.new_table({
      results = results,
      entry_maker = function(line)
        return {
          valid = line ~= nil,
          value = line,
          ordinal = label_fn(line),
          display = label_fn(line),
        }
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = actions.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)

        cb(selection.value)
      end)
      return true
    end,
    sorter = sorters.get_fzy_sorter(),
  }):find()
end

return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require('telescope.builtin')[k]
    end
  end
})
