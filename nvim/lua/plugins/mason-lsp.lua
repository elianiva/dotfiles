local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

return {
  "williamboman/mason-lspconfig.nvim",
  event = { "BufRead" },
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig"
  },
  config = function()
    local mason_lsp = require("mason-lspconfig")
    mason_lsp.setup_handlers {
      function(server_name)
        -- ignore these servers, we only use mason to install the binary
        if server_name == "ts_ls" then
          return
        end
        if server_name == "basedpyright" then
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
            settings = {
              basedpyright = {
                analysis = {
                  autoSearchPaths = true,
                  diagnosticMode = "workspace",
                  useLibraryCodeForTypes = true,
                  diagnosticSeverityOverrides = {
                    reportUnknownVariableType = false,
                  }
                },
              },
            }
          }
          return
        end
        require("lspconfig")[server_name].setup {
            capabilities = capabilities,
        }
      end,
    }
  end
}
