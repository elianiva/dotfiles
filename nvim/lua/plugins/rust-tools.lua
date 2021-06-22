local M = {}

M.plugin = {
  "simrat39/rust-tools.nvim",
  ft = "rust",
  wants = {
    "nvim-lspconfig",
  },
  config = function()
    require("plugins.rust-tools").config()
  end,
}

M.config = function()
  require("rust-tools").setup {
    tools = {
      inlay_hints = {
        show_parameter_hints = true,
        parameter_hints_prefix = "  <- ",
        other_hints_prefix = "  => ",
      },
      hover_actions = {
        border = Util.borders,
      },
    },
    server = {
      on_attach = Util.lsp_on_attach,
      capabilities = (function()
        -- for autoimports
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport =
          true
        capabilities.textDocument.completion.completionItem.resolveSupport = {
          properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
          },
        }
        return capabilities
      end)(),
    },
  }
end

return M
