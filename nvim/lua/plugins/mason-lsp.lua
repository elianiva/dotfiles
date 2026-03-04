return {
  "williamboman/mason-lspconfig.nvim",
  event = { "WinEnter", "BufRead", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  opts = {
    automatic_enable = {
      exclude = {
        "ts_ls"
      }
    }
  },
}
