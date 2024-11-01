local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

-- disable conflicting capabilities conflicting with intelephense
local phpactor_capabilities = vim.lsp.protocol.make_client_capabilities()
phpactor_capabilities.textDocument.hover.dynamicRegistration = false
phpactor_capabilities.textDocument.documentSymbol.dynamicRegistration = false
phpactor_capabilities.textDocument.references.dynamicRegistration = false
phpactor_capabilities.textDocument.completion.dynamicRegistration = false
phpactor_capabilities.textDocument.formatting.dynamicRegistration = false
phpactor_capabilities.textDocument.definition.dynamicRegistration = false
phpactor_capabilities.textDocument.implementation.dynamicRegistration = true
phpactor_capabilities.textDocument.typeDefinition.dynamicRegistration = false
phpactor_capabilities.textDocument.diagnostic.dynamicRegistration = true

-- disable conflicting capabilities conflicting with phpactor
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
		mason_lsp.setup_handlers({
			function(server_name)
				-- ignore these servers, we only use mason to install the binary
				if server_name == "ts_ls" then
					return
				end

				-- use custom capabilities for phpactor
				if server_name == "phpactor" then
					require("lspconfig")[server_name].setup({
						capabilities = phpactor_capabilities,
					})
					return
				end
				if server_name == "intelephense" then
					require("lspconfig")[server_name].setup({
						capabilities = intelephense_capabilities,
					})
					return
				end

				if server_name == "basedpyright" then
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
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
					return
				end

				require("lspconfig")[server_name].setup({
					capabilities = capabilities,
					on_attach = function(client)
            -- disable inlay hints
            vim.lsp.inlay_hint.enable(false)
          end,
				})
			end,
		})

    -- other manual stuff that comes from nix shell
    local lsp = require("lspconfig")
    lsp.ocamlls.setup {
      cmd = { "ocamllsp", "--stdio" },
      filetypes = { "ocaml", "ocaml_interface" },
    }
	end,
}
