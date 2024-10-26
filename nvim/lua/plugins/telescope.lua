---@param picker string Telescope picker
local function telescope_fn(picker)
	return function()
		local builtin = require("telescope.builtin")
		builtin[picker]()
	end
end

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-frecency.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			lazy = true,
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
	},
	keys = {
		{ "<C-p>", telescope_fn("find_files"), desc = "Find Files" },
		{ "<leader>ff", telescope_fn("find_files"), desc = "Find Files" },
		{ "<leader>fg", telescope_fn("live_grep"), desc = "Find Text" },
		{ "<leader>fb", telescope_fn("buffers"), desc = "Find Buffers" },
		{ "<leader>fh", telescope_fn("help_tags"), desc = "Find Help" },
		{ "<leader>fo", telescope_fn("frecency"), desc = "Find Old Files (Frecency)" },
		{ "<leader>ft", telescope_fn("tags"), desc = "Find Tags" },
		{ "<leader>fw", telescope_fn("grep_string"), desc = "Find Word" },
		{ "<leader>fd", telescope_fn("diagnostics"), desc = "Document Diagnostics" },
		-- LSP related pickers
		{ "<leader>fls", telescope_fn("lsp_document_symbols"), desc = "LSP Document Symbols" },
		{ "<leader>fld", telescope_fn("lsp_definitions"), desc = "LSP Definitions" },
		{ "<leader>flt", telescope_fn("lsp_type_definitions"), desc = "LSP Type Definitions" },
		{ "<leader>fli", telescope_fn("lsp_implementations"), desc = "LSP Implementations" },
		{ "<leader>flr", telescope_fn("lsp_references"), desc = "LSP References" },
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
          width = 0.5,
          prompt = " ",
          height = 6,
          previewer = false,
        })
			},
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
			},
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
			},
		},
	},
}
