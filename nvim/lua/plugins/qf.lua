return {
  'stevearc/quicker.nvim',
  event = "FileType qf",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    highlight = {
      treesitter = true,
      load_buffers = false,
      lsp = false,
    }
  },
}
