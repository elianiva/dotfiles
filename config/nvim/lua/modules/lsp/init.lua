local lspconfig = require "lspconfig"

-- override handlers
pcall(require, "modules.lsp.handlers")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.documentationFormat = {
  "markdown",
}
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = false
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport =
  true
capabilities.textDocument.completion.completionItem.tagSupport = {
  valueSet = { 1 },
}
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}

local servers = {
  -- denols = {
  --   filetypes = { "javascript", "typescript", "typescriptreact" },
  --   settings = {
  --     documentFormatting = false,
  --     lint = true,
  --     unstable = true,
  --     config = "./tsconfig.json"
  --   }
  -- },
  tsserver = {
    init_options = { documentFormatting = false },
  },
  sumneko_lua = require("modules.lsp.sumneko").config,
  jsonls = require("modules.lsp.json").config,
  svelte = require("modules.lsp.svelte").config,
  html = { cmd = { "vscode-html-language-server", "--stdio" } },
  cssls = { cmd = { "vscode-css-language-server", "--stdio" } },
  intelephense = {},
  -- omnisharp = {
  --   cmd = { "omnisharp" }
  -- },
  clangd = {},
  rnix = {},
  gopls = {
    settings = {
      gopls = {
        codelenses = {
          references = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          generate = true,
        },
        gofumpt = true,
      },
    },
  },
  pyright = {},
  texlab = {},
  ["null-ls"] = {},
}

require("plugins.null-ls").setup()

for name, opts in pairs(servers) do
  if type(opts) == "function" then
    opts()
  else
    local client = lspconfig[name]
    client.setup(vim.tbl_extend("force", {
      flags = { debounce_text_changes = 150 },
      on_attach = Util.lsp_on_attach,
      on_init = Util.lsp_on_init,
      capabilities = capabilities,
    }, opts))
  end
end
