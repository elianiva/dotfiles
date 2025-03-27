return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
	},
	-- cmd = "MCPHub", -- lazily start the hub when `MCPHub` is called
	build = "bun add -g mcp-hub@latest", -- Installs required mcp-hub npm module
	config = function()
		require("mcphub").setup({
			-- Required options
			port = 6969, -- Port for MCP Hub server
			config = vim.fn.expand("~/.config/nvim/mcpservers.json"), -- Absolute path to config file

			log = {
				level = vim.log.levels.WARN,
				to_file = false,
				file_path = nil,
				prefix = "MCPHub",
			},
		})
	end,
}
