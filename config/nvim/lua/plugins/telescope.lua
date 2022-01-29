local M = {}

local ignored_list = {
  "%.png",
  "%.jpg",
  "%.webp",
  "node_modules",
  "vendor",
  "*%.min%.*",
  "dotbot",
}

M.config = function()
  local _, telescope = pcall(require, "telescope")
  local actions = require "telescope.actions"

  M.no_preview = function(opts)
    return vim.tbl_extend(
      "force",
      require("telescope.themes").get_dropdown {
        borderchars = {
          { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        layout_config = {
          width = 0.6,
        },
        previewer = false,
      },
      opts or {}
    )
  end

  M.dropdown = function(opts)
    return vim.tbl_extend(
      "force",
      require("telescope.themes").get_dropdown {
        borderchars = {
          { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        layout_config = {
          width = 0.6,
        },
      },
      opts or {}
    )
  end

  telescope.setup {
    defaults = {
      scroll_strategy = "cycle",
      selection_strategy = "reset",
      layout_strategy = "flex",
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      layout_config = {
        horizontal = {
          width = 0.8,
          height = 0.8,
          preview_width = 0.6,
        },
        vertical = {
          height = 0.8,
          preview_height = 0.5,
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,

          ["<C-v>"] = actions.select_vertical,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-t>"] = actions.select_tab,

          ["<C-c>"] = actions.close,
          -- ["<Esc>"] = actions.close,

          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<Tab>"] = actions.toggle_selection,
          -- ["<C-r>"] = actions.refine_result,
        },
        n = {
          ["<CR>"] = actions.select_default + actions.center,
          ["<C-v>"] = actions.select_vertical,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-t>"] = actions.select_tab,
          ["<Esc>"] = actions.close,

          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,

          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-q>"] = actions.send_to_qflist,
          ["<Tab>"] = actions.toggle_selection,
        },
      },
    },
    pickers = {
      grep_string = {
        file_ignore_patterns = ignored_list,
      },
      find_files = {
        file_ignore_patterns = ignored_list,
      },
      lsp_refernces = M.dropdown(),
      lsp_code_actions = M.no_preview(),
      current_buffer_fuzzy_find = M.no_preview(),
    },
    extensions = {
      ["ui-select"] = M.no_preview(),
      fzf = {
        override_generic_sorter = true,
        override_file_sorter = true,
      },
    },
  }

  telescope.load_extension "fzf" -- Sorter using fzf algorithm
  telescope.load_extension "ui-select" -- vim.ui.select

  M.builtins = function()
    require("telescope.builtin").builtin(M.no_preview())
  end

  M.workspace_symbols = function()
    require("telescope.builtin").lsp_workspace_symbols {
      path_display = { "absolute" },
    }
  end

  M.grep_prompt = function()
    require("telescope.builtin").grep_string {
      path_display = { "shorten" },
      search = vim.fn.input "Grep String > ",
      only_sort_text = true,
      use_regex = true,
    }
  end

  local map = vim.keymap.set

  -- toggle telescope.nvim
  map("n", "<C-p>", require("telescope.builtin").find_files, {
    desc = "Fuzzy find files using Telescope",
    noremap = true,
    silent = true,
  })

  map("n", "<C-f>", M.grep_prompt, {
    desc = "Fuzzy grep files using Telescope",
    noremap = true,
    silent = true,
  })

  map("n", "<Leader>ft", M.builtins, {
    desc = "Fuzzy grep files using Telescope",
    noremap = true,
    silent = true,
  })

  map("n", "<Leader>fb", require("telescope.builtin").current_buffer_fuzzy_find, {
    desc = "Fuzzy grep current buffer content using Telescope",
    noremap = true,
    silent = true,
  })
end

return M
