local borderchars = {
  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
  prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
  results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
  preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
}

local function no_preview(opts)
  return vim.tbl_extend(
    "force",
    require("telescope.themes").get_dropdown {
      borderchars = borderchars,
      layout_config = {
        width = 0.6,
      },
      previewer = false,
    },
    opts or {}
  )
end

local function dropdown(opts)
  return vim.tbl_extend(
    "force",
    require("telescope.themes").get_dropdown {
      borderchars = borderchars,
      layout_config = {
        width = 0.6,
      },
    },
    opts or {}
  )
end

local function builtins()
  require("telescope.builtin").builtin(no_preview())
end

local function workspace_symbols()
  require("telescope.builtin").lsp_workspace_symbols {
    path_display = { "absolute" },
  }
end

local function grep_prompt()
  require("telescope.builtin").grep_string {
    path_display = { "shorten" },
    search = vim.fn.input "Grep String > ",
    only_sort_text = true,
    use_regex = true,
  }
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "kyazdani42/nvim-web-devicons",
      "tami5/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    cmd = "Telescope",
    version = false,
    opts = {
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
            ["<C-j>"] = function(...)
              require("telescope.actions").move_selection_next(...)
            end,
            ["<C-k>"] = function(...)
              require("telescope.actions").move_selection_previous(...)
            end,
            ["<C-v>"] = function(...)
              require("telescope.actions").select_vertical(...)
            end,
            ["<C-x>"] = function(...)
              require("telescope.actions").select_horizontal(...)
            end,
            ["<C-t>"] = function(...)
              require("telescope.actions").select_tab(...)
            end,
            ["<C-c>"] = function(...)
              require("telescope.actions").close(...)
            end,
            ["<C-u>"] = function(...)
              require("telescope.actions").preview_scrolling_up(...)
            end,
            ["<C-d>"] = function(...)
              require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-q>"] = function(...)
              require("telescope.actions").smart_send_to_qflist(...)
              require("telescope.actions").open_qflist(...)
            end,
            ["<Tab>"] = function(...)
              require("telescope.actions").toggle_selection(...)
            end,
          },
          n = {
            ["<CR>"] = function(...)
              require("telescope.actions").select_default(...)
              require("telescope.actions").center(...)
            end,
            ["<C-v>"] = function(...)
              require("telescope.actions").select_vertical(...)
            end,
            ["<C-x>"] = function(...)
              require("telescope.actions").select_horizontal(...)
            end,
            ["<C-t>"] = function(...)
              require("telescope.actions").select_tab(...)
            end,
            ["<Esc>"] = function(...)
              require("telescope.actions").close(...)
            end,
            ["j"] = function(...)
              require("telescope.actions").move_selection_next(...)
            end,
            ["k"] = function(...)
              require("telescope.actions").move_selection_previous(...)
            end,
            ["<C-u>"] = function(...)
              require("telescope.actions").preview_scrolling_up(...)
            end,
            ["<C-d>"] = function(...)
              require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-q>"] = function(...)
              require("telescope.actions").send_to_qflist(...)
            end,
            ["<Tab>"] = function(...)
              require("telescope.actions").toggle_selection(...)
            end,
          },
        },
      },
      -- pickers = {
      --   grep_string = dropdown {
      --     file_ignore_patterns = ignored_list,
      --   },
      --   find_files = {
      --     file_ignore_patterns = ignored_list,
      --   },
      --   lsp_references = dropdown(),
      --   lsp_document_symbols = dropdown(),
      --   current_buffer_fuzzy_find = no_preview(),
      -- },
      -- extensions = {
      --   ["ui-select"] = no_preview(),
      --   fzf = {
      --     override_generic_sorter = true,
      --     override_file_sorter = true,
      --   },
      -- },
    },
    -- keys = {
    --   {
    --     "<C-p>",
    --     require("telescope.builtin").find_files,
    --     noremap = true,
    --     silent = true,
    --     desc = "Fuzzy find files using Telescope",
    --   },
    --   {
    --     "<C-f>",
    --     grep_prompt,
    --     desc = "Fuzzy grep files using Telescope",
    --     noremap = true,
    --     silent = true,
    --   },
    --   {
    --     "<Leader>ft",
    --     builtins,
    --     desc = "Browse Telescope builtin pickers",
    --     noremap = true,
    --     silent = true,
    --   },
    --   {
    --     "<Leader>fb",
    --     require("telescope.builtin").current_buffer_fuzzy_find,
    --     desc = "Fuzzy grep current buffer content using Telescope",
    --     noremap = true,
    --     silent = true,
    --   }
    -- },
    config = function(_, opts)
      local _, telescope = pcall(require, "telescope")
      telescope.setup(opts)
      telescope.load_extension "fzf" -- Sorter using fzf algorithm
      telescope.load_extension "ui-select" -- vim.ui.select
    end
  }
}
