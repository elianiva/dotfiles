local lspconfig = require "lspconfig"

-- override handlers
require "modules.lsp.handlers"

local capabilities = require("cmp_nvim_lsp").update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

local servers = {
  -- denols = {
  --   filetypes = { "javascript", "typescript", "typescriptreact" },
  --   settings = {
  --     documentFormatting = false,
  --     lint = true,
  --     unstable = true,
  --     config = "./tsconfig.json",
  --   },
  -- },
  tsserver = {
    init_options = vim.tbl_deep_extend(
      "force",
      require("nvim-lsp-ts-utils").init_options,
      {
        preferences = {
          importModuleSpecifierEnding = "auto",
          importModuleSpecifierPreference = "shortest",
        },
        documentFormatting = false,
      }
    ),
    settings = {
      completions = {
        completeFunctionCalls = true,
      },
    },
  },
  sumneko_lua = require("modules.lsp.sumneko").config,
  jsonls = require("modules.lsp.json").config,
  svelte = require("modules.lsp.svelte").config,
  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
  },
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
  },
  intelephense = {},
  -- fsautocomplete = {},
  -- omnisharp = {
  --   cmd = {
  --     "omnisharp",
  --     "--languageserver",
  --     "--hostPID",
  --     tostring(vim.fn.getpid()),
  --   },
  -- },
  clangd = {},
  -- vuels = {}, -- vue 2 only
  volar = {}, -- vue 3 only
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
  eslint = {},
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
