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
	event = { "BufRead" },
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

					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						on_attach = function()
							vim.lsp.inlay_hint.enable(false)
						end,
					})
				end,

				["ts_ls"] = function()
					-- disable ts_ls
				end,

				["intelephense"] = function()
					require("lspconfig").intelephense.setup({
						capabilities = intelephense_capabilities,
						init_options = {
							licenceKey = "EducationalCode",
						},
					})
				end,

				["basedpyright"] = function()
					require("lspconfig").basedpyright.setup({
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

		-- other manual stuff that comes from nix shell
		local lsp = require("lspconfig")
		lsp.ocamlls.setup({
			cmd = { "ocamllsp", "--stdio" },
			filetypes = { "ocaml", "ocaml_interface" },
		})
	end,
}
