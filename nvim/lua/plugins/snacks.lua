return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
    -- stylua: ignore start
		{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications", },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer", },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", },
		{ "<leader>cR", function() Snacks.rename() end, desc = "Rename File", },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
		{ "<C-p>",      function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>fg", function() Snacks.picker.grep() end, desc = "Find Text", },
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Text", },
    -- lsp related pickers
		{ "<leader>fls", function() Snacks.picker.lsp_symbols() end, desc = "LSP Document Symbols", },
		{ "<leader>flr", function() Snacks.picker.lsp_references() end, desc = "LSP References", },
		-- stylua: ignore end
	},
	opts = {
		bigfile = {
			enabled = true,
			notify = true,
		},
		notifier = {
			enabled = true,
			timeout = 3000,
			style = "compact",
			top_down = false,
			margin = {
				bottom = 1,
			},
		},
		quickfile = { enabled = true },
		indent = {
			enabled = true,
			hl = "SnacksIndent",
			scope = {
				enabled = true,
				animate = {
					enabled = false,
				},
			},
		},
		statuscolumn = {
			enabled = false,
		},
		words = { enabled = true },
		styles = {
			notification = {
				wo = { wrap = true },
			},
		},
		picker = {
      ui_select = true,
			layout = {
				reverse = true,
				layout = {
					box = "horizontal",
					backdrop = false,
					width = 0.8,
					height = 0.9,
					border = "none",
					{
						box = "vertical",
						{
							win = "list",
							title = " Results ",
							title_pos = "center",
							border = "single",
						},
						{
							win = "input",
							height = 1,
							border = "single",
							title = "{title} {live} {flags}",
							title_pos = "center",
						},
					},
					{
						win = "preview",
						title = "{preview:Preview}",
						width = 0.5,
						border = "single",
						title_pos = "center",
					},
				},
			},
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				Snacks.toggle.inlay_hints():map("<leader>uh")
			end,
		})
	end,
}
