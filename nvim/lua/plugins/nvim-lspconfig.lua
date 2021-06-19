local M = {}

M.plugin = {
  "neovim/nvim-lspconfig",
  event = "BufRead",
  config = function()
    require("modules.lsp")
  end
}

return M
