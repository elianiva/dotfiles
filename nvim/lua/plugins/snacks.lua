return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
    -- stylua: ignore start
		{ "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode", },
		{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications", },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer", },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", },
		{ "<leader>cR", function() Snacks.rename() end, desc = "Rename File", },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
		{ "<leader>f",      function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>/",      function() Snacks.picker.grep() end, desc = "Find Text" },

    -- lsp related pickers
		{ "<leader>s", function() Snacks.picker.lsp_symbols() end, desc = "LSP Document Symbols", },
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
				reverse = false,
				layout = {
					box = "horizontal",
					backdrop = false,
					width = 0.9,
					height = 0.9,
					border = "none",
					{
						box = "vertical",
            border = "single",
            title = "{title} {live} {flags}",
						{
							win = "input",
							height = 1,
							border = "bottom",
						},
						{
							win = "list",
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
		zen = {
			win = {
				enter = true,
				fixbuf = true,
				minimal = true,
				width = 80,
				height = 0.9,
				backdrop = { transparent = false, blend = 99 },
				keys = { q = false },
				zindex = 40,
				w = {
					snacks_main = true,
				},
			},
      on_open = function()
        vim.wo.signcolumn = "no"
        vim.wo.foldcolumn = "0"
        vim.wo.wrap = true
        vim.wo.linebreak = true
      end,
      toggles = {
        dim = false,
      }
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
