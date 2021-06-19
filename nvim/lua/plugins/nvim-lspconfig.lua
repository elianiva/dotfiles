local M = {}

M.plugin = {
  "neovim/nvim-lspconfig",
  config = function()
    require("modules.lsp")
  end
}

return M
