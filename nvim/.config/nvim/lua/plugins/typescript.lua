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
      expose_as_code_action = "all"
    }
  },
}
