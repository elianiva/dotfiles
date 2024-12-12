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
