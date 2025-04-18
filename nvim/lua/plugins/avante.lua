return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	build = "make",
	enabled = false,
	lazy = false,
	version = "v0.0.23",
	opts = {
		provider = "openai",
		auto_suggestions_provider = "openai",
		-- claude = {
		--   endpoint = "https://api.anthropic.com",
		--   model = "claude-3-5-sonnet-20240620",
		--   api_key_name = "cmd:pass show elianiva/claude",
		--   temperature = 0,
		--   max_tokens = 4096,
		-- },
		openai = {
			endpoint = "https://openrouter.ai/api/v1",
			-- model = "deepseek/deepseek-r1-distill-llama-70b:free",
			-- model = "google/gemini-2.0-flash-001",
			model = "openai/gpt-4o-mini",
			api_key_name = "cmd:pass show elianiva/openrouter",
			temperature = 0,
			max_tokens = 8192,
			disable_tools = true,
		},
		behaviour = {
			auto_suggestions = false,
		},
		windows = {
			width = 40,
			sidebar_header = {
				enabled = true,
				align = "center",
				rounded = false,
			},
			edit = {
				border = "single",
				start_insert = false,
			},
			ask = {
				floating = false,
				border = "single",
			},
		},
		system_prompt = function()
			local hub = require("mcphub").get_hub_instance()
			if hub then
				return hub:get_active_servers_prompt()
			end
		end,
		-- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
		custom_tools = function()
			return {
				require("mcphub.extensions.avante").mcp_tool(),
			}
		end,
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
}
