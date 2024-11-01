return {
	"saghen/blink.cmp",
	lazy = false, -- lazy loading handled internally
	dependencies = "rafamadriz/friendly-snippets",
	version = "v0.*", -- last release is too old
	event = "InsertEnter",
	opts = {
		keymap = {
			["<CR>"] = { "select_and_accept", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
		},
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
