return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	dependencies = "rafamadriz/friendly-snippets",
	version = "v0.*", -- last release is too old
	event = "InsertEnter",
	opts = {
    keymap = { preset = 'enter' },
		windows = {
			autocomplete = {
				border = "single",
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
    fuzzy = {
      use_frecency = true,
      use_proximity = true,
      sorts = { 'label', 'kind', 'score' },
    }
	},
}
