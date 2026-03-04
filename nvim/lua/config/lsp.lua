local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}
capabilities.textDocument.semanticTokens.multilineTokenSupport = true

local ok, blink = pcall(require, "blink.cmp")
if ok then
	capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities(capabilities))
end

-- global lsp settings
vim.lsp.config("*", {
    capabilities = capabilities,
})

-- intelephense specific settings
local intelephense_capabilities = vim.lsp.protocol.make_client_capabilities()
intelephense_capabilities.textDocument.completion.dynamicRegistration = true
vim.lsp.config("intelephense", {
  capabilities = intelephense_capabilities
})

-- basedpyright specific settings
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportUnknownVariableType = false,
        },
      },
    },
  }
})

-- use harper for markdown and typst
vim.lsp.config("harper_ls", {
  filetypes = { "markdown", "typst" }
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local utils = require("config.utils")
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client == nil then
      return
    end

    -- trigger additional capabilities
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
