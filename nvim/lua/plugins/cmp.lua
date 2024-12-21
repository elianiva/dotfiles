return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	dependencies = "rafamadriz/friendly-snippets",
	version = "v0.*", -- last release is too old
	event = "InsertEnter",
	opts = {
		keymap = { preset = "enter" },
		appearance = {
			nerd_font_variant = "normal",
		},
		signature = {
			window = {
				border = "solid",
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			cmdline = {},
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
		},
	},
}
