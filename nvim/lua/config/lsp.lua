vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local utils = require("config.utils")
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client == nil then
      return
    end

    -- Setup additional capabilities
    utils.lsp.additional_capabilities(client)

    -- Setup buffer-specific mappings
    utils.lsp.additional_mappings(args.buf)

    -- Setup buffer-specific autocmds for this LSP client
    if client:supports_method("textDocument/codeLens", args.buf) then
      local group = vim.api.nvim_create_augroup("lsp_codelens_" .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.codelens.refresh()
        end,
      })
    end

    if client:supports_method("textDocument/documentHighlight", args.buf) then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorHoldI", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end
})
