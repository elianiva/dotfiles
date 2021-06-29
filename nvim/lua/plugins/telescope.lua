local M = {}

M.plugin = {
  "~/repos/telescope.nvim",
  module = "telescope",
  keys = {
    {"", "<C-p>"},
    {"", "<C-f>"},
    {"n", "<Leader>f"}
  },
  requires = {
    -- Preview media files in Telescope
    {
      "nvim-telescope/telescope-media-files.nvim",
      after = "telescope.nvim",
    },

    -- A telescope.nvim extension that offers intelligent prioritization
    -- when selecting files from your editing history.
    {
      "nvim-telescope/telescope-frecency.nvim",
      after = "telescope.nvim",
      requires = {
        -- lua sqlite binding
        "tami5/sql.nvim",
      },
    },

    -- FZF style sorter
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
    },

    -- Integration for nvim-dap with telescope.nvim
    {
      "nvim-telescope/telescope-dap.nvim",
      after = "telescope.nvim",
    },
  },
  config = function()
    require("plugins.telescope").config()
  end,
}

M.config = function()
  local _, telescope = pcall(require, "telescope")
  local actions = require "telescope.actions"
  local previewers = require "telescope.previewers"

  local k = vim.keymap
  local nnoremap = k.nnoremap

  local delta = previewers.new_termopen_previewer {
    get_command = function(entry)
      return {
        "git",
        "-c",
        "core.pager=delta",
        "-c",
        "delta.side-by-side=false",
        "diff",
        entry.value .. "^!",
      }
    end,
  }

  M.no_preview = function()
    return require("telescope.themes").get_dropdown {
      borderchars = {
        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
      width = 0.8,
      previewer = false,
    }
  end

  telescope.setup {
    defaults = {
      file_previewer = previewers.vim_buffer_cat.new,
      grep_previewer = previewers.vim_buffer_vimgrep.new,
      qflist_previewer = previewers.vim_buffer_qflist.new,
      scroll_strategy = "cycle",
      selection_strategy = "reset",
      layout_strategy = "flex",
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
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
          ["<Esc>"] = actions.close,

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
      find_files = {
        file_ignore_patterns = { "%.png", "%.jpg", "%.webp" },
      },
      lsp_code_actions = M.no_preview(),
      current_buffer_fuzzy_find = M.no_preview(),
      git_commits = {
        previewer = {
          delta,
          previewers.git_commit_message.new {},
          previewers.git_commit_diff_as_was.new {},
        },
      },
    },
    extensions = {
      fzf = {
        override_generic_sorter = true,
        override_file_sorter = true,
      },
      media_files = {
        filetypes = { "png", "webp", "jpg", "jpeg", "pdf", "mkv" },
        find_cmd = "rg",
      },
      frecency = {
        show_scores = false,
        show_unindexed = true,
        ignore_patterns = { "*.git/*", "*/tmp/*" },
        workspaces = {
          ["nvim"] = "/home/elianiva/.config/nvim",
          ["awesome"] = "/home/elianiva/.config/awesome",
          ["alacritty"] = "/home/elianiva/.config/alacritty",
          ["scratch"] = "/home/elianiva/codes/scratch",
        },
      },
    },
  }

  local builtin = require "telescope.builtin"

  pcall(telescope.load_extension, "fzf") -- superfast sorter
  pcall(telescope.load_extension, "media_files") -- media preview
  pcall(telescope.load_extension, "frecency") -- frecency
  pcall(telescope.load_extension, "dap") -- DAP integrations
  pcall(telescope.load_extension, "npm") -- NPM integrations

  M.arecibo = function()
    telescope.extensions.arecibo.websearch(M.no_preview())
  end

  M.frecency = function()
    telescope.extensions.frecency.frecency(M.no_preview())
  end

  M.npm_script = function()
    telescope.extensions.npm.scripts(M.no_preview())
  end

  M.grep_prompt = function()
    builtin.grep_string {
      shorten_path = true,
      search = vim.fn.input "Grep String > ",
      only_sort_text = true,
      use_regex = true,
    }
  end

  -- toggle telescope.nvim
  nnoremap { "<C-p>", builtin.find_files, { silent = true } }
  nnoremap { "<C-f>", M.grep_prompt, { silent = true } }
  nnoremap { "<Leader>fb", builtin.current_buffer_fuzzy_find, { silent = true } }
  nnoremap { "<Leader>ff", M.frecency, { silent = true } }
  nnoremap { "<Leader>fa", M.arecibo, { silent = true } }
  nnoremap { "<Leader>fl", builtin.file_browser, { silent = true } }
  nnoremap { "<Leader>fg", builtin.git_commits, { silent = true } }
  nnoremap { "<Leader>fns", M.npm_script, { silent = true } }
end

return M