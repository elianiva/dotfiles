vim.cmd[[packadd nvim-lspconfig]]
vim.cmd[[packadd lspsaga.nvim]]

local nvim_lsp = require("lspconfig")
local mappings = require("modules.lsp._mappings")
local is_cfg_present = require("modules._util").is_cfg_present

require("modules.lsp._diagnostic") -- diagnostic stuff

require"lspsaga".init_lsp_saga({
  border_style = 1,
}) -- initialise lspsaga UI

local custom_on_attach = function(client)
  mappings.lsp_mappings()

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

local custom_on_init = function()
  print("Language Server Protocol started!")
end

local custom_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true;

  return capabilities
end

-- use eslint if the eslint config file present
local is_using_eslint = function(_, _, result, client_id)
  if is_cfg_present("/.eslintrc.json") or is_cfg_present("/.eslintrc.js") then
    return
  end

  return vim.lsp.handlers["textDocument/publishDiagnostics"](_, _, result, client_id)
end

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
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

local sumneko_root = os.getenv("HOME") .. "/repos/lua-language-server"
local servers = {
  tsserver = {
    filetypes = { "javascript", "typescript", "typescriptreact" },
    on_attach = function(client)
      mappings.lsp_mappings()
      if client.config.flags then
        client.config.flags.allow_incremental_sync = true
      end
    end,
    handlers = {
      ["textDocument/publishDiagnostics"] = is_using_eslint
    },
    on_init = custom_on_init,
    root_dir = vim.loop.cwd,
  },
  -- denols = {},
  html = {},
  cssls = {},
  intelephense = {},
  jdtls = {
    cmd = {"jdtls"}
  },
  rust_analyzer = {},
  clangd = {},
  gopls = {
    root_dir = vim.loop.cwd
  },
  efm = {
    cmd = { "efm-langserver" },
    on_attach = function(client)
      client.resolved_capabilities.rename = false
      client.resolved_capabilities.hover = false
    end,
    on_init = custom_on_init,
    filetypes = {"javascript", "typescript", "typescriptreact", "svelte"},
    settings = {
      rootMarkers = {".git", "package.json"},
      languages = {
        javascript = { eslint },
        typescript = { eslint },
        typescriptreact = { eslint },
        svelte = { eslint },
      }
    }
  },
  svelte = {
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
      ["textDocument/publishDiagnostics"] = is_using_eslint
    },
    on_init = custom_on_init,
    filetypes = { "svelte" },
    settings = {
      svelte =  {
        plugin = {
          html = {
            completions = {
              enable = true,
              emmet = false
            },
          },
          svelte = {
            completions = {
              enable = true,
              emmet = false
            },
          },
          css = {
            completions = {
              enable = true,
              emmet = false
            },
          },
        }
      }
    },
  },
  sumneko_lua = {
    cmd = {
      sumneko_root
        .. "/bin/Linux/lua-language-server", "-E",
      sumneko_root .. "/main.lua"
    },
    on_attach = custom_on_attach,
    on_init = custom_on_init,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", path = vim.split(package.path, ";"), },
        diagnostics = {
          enable = true,
          globals = {
            "vim", "describe", "it", "before_each", "after_each",
            "awesome", "theme", "client", "P"
          },
        },
      }
    }
  }
}

for name, opts in pairs(servers) do
  local client = nvim_lsp[name]
  client.setup{
    cmd = opts.cmd or client.cmd,
    filetypes = opts.filetypes or client.filetypes,
    on_attach = opts.on_attach or custom_on_attach,
    on_init = opts.on_init or custom_on_init,
    handlers = opts.handlers or client.handlers,
    root_dir = opts.root_dir or client.root_dir,
    capabilities = opts.capabilities or custom_capabilities(),
    settings = opts.settings or {}
  }
end
