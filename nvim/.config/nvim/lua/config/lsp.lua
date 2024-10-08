vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local utils = require("config.utils")
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    utils.lsp.additional_capabilities(client)
    utils.lsp.additional_mappings(args.buf)
  end
})
