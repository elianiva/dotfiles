return {
	"olimorris/codecompanion.nvim",
	config = true,
  lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"folke/noice.nvim",
	},
	keys = {
		{ "<Leader>aa", "<CMD>CodeCompanionChat Toggle<CR>", mode = { "n", "v" } },
		{ "<Leader>ap", "<CMD>CodeCompanionActions<CR>", mode = { "n", "v" } },
	},
	init = function()
		vim.cmd([[cab cc CodeCompanion]])
		require("plugins.codecompanion.notification"):init()
	end,
	opts = {
		strategies = {
			chat = {
				adapter = "openrouter",
			},
			inline = {
				adapter = "openrouter",
			},
		},
		adapters = {
			openrouter = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						url = "https://openrouter.ai/api",
						api_key = "cmd:pass show elianiva/openrouter",
						chat_url = "/v1/chat/completions",
					},
					schema = {
						model = {
							default = "google/gemini-2.0-flash-001",
						},
					},
				})
			end,
		},
	},
}
