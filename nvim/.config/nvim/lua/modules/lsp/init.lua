vim.cmd[[packadd nvim-lspconfig]]

local nvim_lsp = require('lspconfig')
local mappings = require('modules.lsp._mappings')

require('modules.lsp._svelte') -- svelteserver config
require('modules.lsp._custom_handlers') -- override hover callback
require('modules.lsp._diagnostic') -- diagnostic stuff

local custom_on_attach = function(client)
  mappings.lsp_mappings()

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

local custom_on_init = function()
  print('Language Server Protocol started!')
end

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' },
  on_attach = function(client)
    mappings.lsp_mappings()

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end

    client.resolved_capabilities.document_formatting = false
  end,
  on_init = custom_on_init,
  handlers = {
    ["textDocument/publishDiagnostics"] = function() return end
  },
  root_dir = function() return vim.loop.cwd() end,
  settings = {
    javascript = {
      suggest = { enable = false },
      validate = { enable = false }
    }
  }
}

nvim_lsp.html.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.cssls.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.rust_analyzer.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init,
}

nvim_lsp.clangd.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init
}

nvim_lsp.gopls.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init,
  root_dir = function() return vim.loop.cwd() end,
}

local eslint = {
  lintCommand = "eslint -f unix --stdin",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"}
}

local get_prettier = function()
  if not vim.fn.empty(vim.fn.glob(vim.loop.cwd() .. '/.prettierrc')) then
    return "prettier --config ./.prettierrc"
  else
    return "prettier --config ~/.config/nvim/.prettierrc"
  end
end

local prettier = {
  formatCommand = get_prettier()
}

nvim_lsp.efm.setup{
  cmd = {"efm-langserver"},
  on_attach = function(client)
    client.resolved_capabilities.rename = false
    client.resolved_capabilities.hover = false
  end,
  on_init = custom_on_init,
  settings = {
    rootMarkers = {vim.loop.cwd()},
    languages = {
      javascript = { eslint, prettier }
    }
  }
}

nvim_lsp.svelte.setup{
  on_attach = function(client)
    mappings.lsp_mappings()

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.server_capabilities.completionProvider.triggerCharacters = {
      ".", '"', "'", "`", "/", "@", "*",
      "#", "$", "+", "^", "(", "[", "-", ":"
    }
  end,
  on_init = custom_on_init,
  filetypes = { 'svelte' },
  settings = {
    svelte =  {
      plugin = {
        html = {
          completions = {
            enable = true,
            emmet = false
          },
        },
      }
    }
  },
}

nvim_lsp.sumneko_lua.setup{
  on_attach = custom_on_attach,
  on_init = custom_on_init,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = vim.split(package.path, ';'), },
      completion = { keywordSnippet = "Disable" },
      diagnostics = {
        enable = true,
        globals = {
          "vim", "describe", "it", "before_each", "after_each",
          "awesome", "theme", "client"
        },
      },
    }
  }
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
