return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-frecency.nvim'
  },
  cmd = {
    'Telescope',
  },
  keys = {
    { "<C-p>",       "<cmd>Telescope find_files<cr>",               desc = "Find Files" },
    { "<leader>ff",  "<cmd>Telescope find_files<cr>",               desc = "Find Files" },
    { "<leader>fg",  "<cmd>Telescope live_grep<cr>",                desc = "Find Text" },
    { "<leader>fb",  "<cmd>Telescope buffers<cr>",                  desc = "Find Buffers" },
    { "<leader>fh",  "<cmd>Telescope help_tags<cr>",                desc = "Find Help" },
    { "<leader>fo",  "<cmd>Telescope frecency<cr>",                 desc = "Find Old Files (Frecency)" },
    { "<leader>ft",  "<cmd>Telescope tags<cr>",                     desc = "Find Tags" },
    { "<leader>fw",  "<cmd>Telescope grep_string<cr>",              desc = "Find Word" },
    -- LSP related pickers
    { "<leader>fls", "<cmd>Telescope lsp_document_symbols<cr>",     desc = "LSP Document Symbols" },
    { "<leader>fld", "<cmd>Telescope lsp_definitions<cr>",          desc = "LSP Definitions" },
    { "<leader>flt", "<cmd>Telescope lsp_type_definitions<cr>",     desc = "LSP Type Definitions" },
    { "<leader>fli", "<cmd>Telescope lsp_implementations<cr>",      desc = "LSP Implementations" },
    { "<leader>flr", "<cmd>Telescope lsp_references<cr>",           desc = "LSP References" },
    { "<leader>fla", "<cmd>lua vim.lsp.buf.code_action()<cr>",         desc = "LSP Code Actions" },
    { "<leader>flj", "<cmd>Telescope lsp_document_diagnostics<cr>", desc = "LSP Diagnostics" },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.load_extension("ui-select")
    telescope.load_extension("frecency")
    telescope.setup(opts)
  end,
  opts = {
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({
          previewer = false
        })
      }
    },
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
      }
    }
  }
}
