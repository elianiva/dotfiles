return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	dependencies = "rafamadriz/friendly-snippets",
	version = "v0.*", -- last release is too old
	event = "InsertEnter",
	opts = {
		keymap = {
			preset = "enter",
		},
		cmdline = {
			keymap = {
				preset = "none",
			},
		},
		appearance = {
			nerd_font_variant = "normal",
		},
		signature = {
			window = {
				border = "solid",
			},
		},
		fuzzy = { implementation = "prefer_rust" },
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		completion = {
			accept = {
				create_undo_point = true,
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				border = "single",
				auto_show = function(ctx)
					return ctx.mode ~= "cmdline"
				end,
			},
			documentation = {
				window = {
					border = "solid",
				},
			},
			trigger = {
				show_on_insert_on_trigger_character = true,
				-- these are annoying
				show_on_x_blocked_trigger_characters = { "'", '"', "(", "[", "{" },
			},
			list = {
				selection = {
					preselect = function(ctx)
						return ctx.mode ~= "cmdline"
					end,
					auto_insert = function(ctx)
						return ctx.mode ~= "cmdline"
					end,
				},
			},
		},
	},
	opts_extend = { "sources.default" },
}
