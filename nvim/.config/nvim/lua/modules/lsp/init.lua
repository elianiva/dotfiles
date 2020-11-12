local nvim_lsp = require('nvim_lsp')
local diagnostic = require('diagnostic')
local mappings = require('modules.lsp._mappings')

require('modules.lsp._svelte')
require('modules.lsp._diagnostic')
require('modules.lsp._custom_callbacks')

local custom_on_attach = function()
  diagnostic.on_attach() -- sweet diagnostics (will be replaced once TJ's PR merged)
  mappings.lsp_mappings() -- lsp related mappings
end

local custom_on_init = function()
  print('Language Server Protocol started!')
end

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' },
  on_attach = custom_on_attach,
  on_init = custom_on_init,
  root_dir = function() return vim.loop.cwd() end
}

nvim_lsp.html.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.cssls.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.svelte.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.sumneko_lua.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = vim.split(package.path, ';'), },
      completion = { keywordSnippet = "Disable", },
      diagnostics = { enable = true, globals = {
        "vim", "describe", "it", "before_each", "after_each" },
      },
    }
  }
}

nvim_lsp.rust_analyzer.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init,
}

-- temporarily disable this stuff, my laptop couldn't handle multiple lsp sadly
if false then
nvim_lsp.diagnosticls.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact', 'svelte' },
  on_attach = custom_on_attach,
  on_init = function() print("Diagnosticls started") end,
  init_options = {
    filetypes = {
      javascript = "eslint",
      svelte = "eslint",
      typescriptreact = "eslint",
    },
    linters = {
      eslint = {
        sourceName = "eslint",
        command = "./node_modules/.bin/eslint",
        rootPatterns = { ".git" },
        debounce = 100,
        args = {
          "--stdin",
          "--stdin-filename",
          "%filepath",
          "--format",
          "json",
        },
        parseJson = {
          errorsRoot = "[0].messages",
          line = "line",
          column = "column",
          endLine = "endLine",
          endColumn = "endColumn",
          message = "${message} [${ruleId}]",
          security = "severity",
        };
        securities = {
          [2] = "error",
          [1] = "warning"
        }
      }
    }
  }
}
end
