local M = {}

M.plugin = {
  "mfussenegger/nvim-jdtls",
  wants = "telescope.nvim",
  setup = function()
    vim.cmd [[
      augroup jdtls
      au!
      au FileType java lua require("plugins.nvim-jdtls").setup()
      augroup END
    ]]
  end,
}

M.setup = function()
  require("jdtls").start_or_attach {
    cmd = { "jdt-language-server" },
    on_attach = Util.lsp_on_attach,
  }
end

return M
