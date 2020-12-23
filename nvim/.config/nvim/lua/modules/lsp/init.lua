vim.cmd[[packadd nvim-lspconfig]]

local nvim_lsp = require('lspconfig')
local mappings = require('modules.lsp._mappings')
local is_cfg_present = require('modules._util').is_cfg_present

require('modules.lsp._svelte') -- svelteserver config
require('modules.lsp._custom_handlers') -- override hover callback
require('modules.lsp._diagnostic') -- diagnostic stuff

local custom_on_attach = function(client)
  mappings.lsp_mappings()

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end

  client.resolved_capabilities.document_formatting = false
end

local custom_on_init = function()
  print('Language Server Protocol started!')
end

-- use eslint if the eslint config file present
local is_using_eslint = function(_, _, result, client_id)
  if is_cfg_present("/.eslintrc.json") or is_cfg_present("/.eslintrc.js") then
    return
  end

  -- TODO(elianiva): find a better solution using `vim.lsp.with`, this seems
  --                 like a hacky way of doing it
  return vim.lsp.diagnostic.on_publish_diagnostics(_, _, result, client_id, _, {
    underline = true,
    virtual_text = {
      prefix = "»",
      spacing = 4,
    },
    signs = true,
    update_in_insert = false,
  })
end

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' },
  on_attach = function(client)
    mappings.lsp_mappings()

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
  end,
  handlers = {
    ['textDocument/publishDiagnostics'] = is_using_eslint
  },
  on_init = custom_on_init,
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
  lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  rootMarkers = {
    "package.json",
    ".eslintrc.js",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
  }
}

local prettier = {
  formatCommand = (
    function()
      if is_cfg_present("/.prettierrc") then
        return "prettier --config ./.prettierrc"
      else
        return "prettier --config ~/.config/nvim/.prettierrc"
      end
    end
  )()
}

local gofmt= {
  formatCommand = "gofmt"
}

local rustfmt = {
  formatCommand = "rustfmt --emit=stdout"
}

-- TODO(elianiva): find a way to fix wrong formatting
nvim_lsp.efm.setup{
  cmd = {"efm-langserver"},
  on_attach = function(client)
    client.resolved_capabilities.rename = false
    client.resolved_capabilities.hover = false
  end,
  on_init = custom_on_init,
  init_options = { documentFormatting = true },
  filetypes = {"javascript", "typescript", "typescriptreact", "svelte"},
  settings = {
    rootMarkers = {".git", "package.json"},
    languages = {
      javascript = { eslint, prettier },
      typescript = { eslint, prettier },
      typescriptreact = { eslint, prettier },
      svelte = { eslint, prettier },
      -- html = { prettier },
      -- css = { prettier },
      -- jsonc = { prettier },
      -- go = { gofmt },
      -- rust = { rustfmt },
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
  handlers = {
    ['textDocument/publishDiagnostics'] = is_using_eslint
  },
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
