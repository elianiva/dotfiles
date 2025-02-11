return {
  "pmizio/typescript-tools.nvim",
  ft = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig"
  },
  opts = {
    settings = {
      separate_diagnostic_server = true,
      publish_diagnostic_on = "insert_leave",
      expose_as_code_action = "all",
      tsserver_max_memory = 1024,
      tsserver_file_preferences = {
        -- includeInlayParameterNameHints = "all",
        -- includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        -- includeInlayFunctionParameterTypeHints = true,
        -- includeInlayVariableTypeHints = true,
        -- includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        -- includeInlayPropertyDeclarationTypeHints = true,
        -- includeInlayFunctionLikeReturnTypeHints = true,
        -- includeInlayEnumMemberValueHints = true,

        includeCompletionsForModuleExports = true,
        quotePreference = "auto",
      },
    }
  },
}
