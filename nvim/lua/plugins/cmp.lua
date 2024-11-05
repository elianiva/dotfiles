return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	dependencies = "rafamadriz/friendly-snippets",
	version = "v0.*", -- last release is too old
	event = "InsertEnter",
	opts = {
		keymap = "enter",
		windows = {
			autocomplete = {
				border = "none",
			},
			documentation = {
				border = "solid",
			},
			signature_help = {
				border = "solid",
			},
		},
		highlight = {
			use_nvim_cmp_as_default = true,
		},
		nerd_font_variant = "normal",
		accept = {
			create_undo_point = true,
			auto_brackets = {
				enabled = true,
			},
		},
		trigger = {
			signature_help = {
				enabled = false,
				show_on_insert_on_trigger_character = false,
			},
		},
	},
}
