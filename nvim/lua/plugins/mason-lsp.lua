local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local ok, blink = pcall(require, "blink.cmp")
if ok then
	capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities(capabilities))
end

local intelephense_capabilities = vim.lsp.protocol.make_client_capabilities()
intelephense_capabilities.textDocument.completion.dynamicRegistration = true

return {
	"williamboman/mason-lspconfig.nvim",
	event = { "WinEnter", "BufRead", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local mason_lsp = require("mason-lspconfig")
		mason_lsp.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(server_name)
					if server_name == "ts_ls" then
						return
					end

					vim.lsp.config[server_name].setup({
						capabilities = capabilities,
						on_attach = function()
							vim.lsp.inlay_hint.enable(false)
						end,
					})
				end,

        ["harper_ls"] = function()
					vim.lsp.config.harper_ls.setup({
						capabilities = capabilities,
            filetypes = { "markdown", "typst" }
					})
        end,

				["ts_ls"] = function()
					-- disable ts_ls, we have its own plugin
				end,

				["intelephense"] = function()
					vim.lsp.config.intelephense.setup({
						capabilities = intelephense_capabilities,
					})
				end,

				["basedpyright"] = function()
					vim.lsp.config.basedpyright.setup({
						capabilities = capabilities,
						on_attach = function()
							-- disable inlay hints
							vim.lsp.inlay_hint.enable(false)
						end,
						settings = {
							basedpyright = {
								analysis = {
									autoSearchPaths = true,
									diagnosticMode = "workspace",
									useLibraryCodeForTypes = true,
									diagnosticSeverityOverrides = {
										reportUnknownVariableType = false,
									},
								},
							},
						},
					})
				end,
			},
		})
	end,
}
