vim.cmd [[packadd nvim-lspconfig]]

local nvim_lsp = require("lspconfig")
local mappings = require("modules.lsp._mappings")
local is_cfg_present = require("modules._util").is_cfg_present

local custom_on_attach = function()
  mappings.lsp_mappings()
  require("lsp_signature").on_attach {
      bind = true,
      doc_lines = 2,
      hint_enable = false,
      handler_opts = {
        border = Util.borders
      }
    }
end

pcall(require, "modules.lsp._handlers")

local custom_on_init = function(client)
  print("Language Server Protocol started!")

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end
end

local custom_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

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
  lintFormats = { "%f:%l:%c: %m" },
}

local denofmt = {
  formatCommand = "cat ${INPUT} | deno fmt -",
  formatStdin = true,
}

local sumneko_root = os.getenv("HOME") .. "/repos/lua-language-server"
local servers = {
  tsserver = {
    filetypes = { "javascript", "typescript", "typescriptreact" },
    init_options = {
      documentFormatting = false,
    },
    handlers = {
      ["textDocument/publishDiagnostics"] = is_using_eslint,
    },
    on_init = custom_on_init,
    on_attach = function()
      mappings.lsp_mappings()
      require("nvim-lsp-ts-utils").setup {}
    end,
    root_dir = vim.loop.cwd,
  },
  -- denols = {
  --   filetypes = { "javascript", "typescript", "typescriptreact" },
  --   root_dir = vim.loop.cwd,
  --   settings = {
  --     documentFormatting = true,
  --     lint = true
  --   }
  -- },
  html = {
    cmd = { "vscode-html-language-server", "--stdio" }
  },
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" }
  },
  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_dir = vim.loop.cwd
  },
  hls = {
    root_dir = vim.loop.cwd
  },
  -- phpactor = {
  --   root_dir = vim.loop.cwd
  -- },
  intelephense = {
    root_dir = vim.loop.cwd
  },
  clangd = {},
  pyright = {},
  gopls = {
    root_dir = vim.loop.cwd,
  },
  efm = {
    cmd = { "efm-langserver" },
    on_attach = function(client)
      client.resolved_capabilities.rename = false
      client.resolved_capabilities.hover = false
      client.resolved_capabilities.document_formatting = true
      client.resolved_capabilities.completion = false
    end,
    on_init = custom_on_init,
    filetypes = { "javascript", "typescript", "typescriptreact", "svelte" },
    settings = {
      rootMarkers = { ".git", "package.json" },
      languages = {
        javascript = { eslint, denofmt },
        typescript = { eslint, denofmt },
        typescriptreact = { eslint },
        svelte = { eslint },
      },
    },
  },
  svelte = {
    on_attach = function(client)
      mappings.lsp_mappings()

      client.server_capabilities.completionProvider.triggerCharacters = {
        ".", '"', "'", "`", "/", "@", "*",
        "#", "$", "+", "^", "(", "[", "-", ":"
      }
    end,
    handlers = {
      ["textDocument/publishDiagnostics"] = is_using_eslint,
    },
    on_init = custom_on_init,
    filetypes = { "svelte" },
    settings = {
      svelte = {
        plugin = {
          html = {
            completions = {
              enable = true,
              emmet = false,
            },
          },
          svelte = {
            completions = {
              enable = true,
              emmet = false,
            },
          },
          css = {
            completions = {
              enable = true,
              emmet = true,
            },
          },
        },
      },
    },
  },
  sumneko_lua = {
    cmd = {
      sumneko_root .. "/bin/Linux/lua-language-server",
      "-E",
      sumneko_root .. "/main.lua",
    },
    on_attach = custom_on_attach,
    on_init = custom_on_init,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
        diagnostics = {
          enable = true,
          globals = {
            "vim", "describe", "it", "before_each", "after_each",
            "awesome", "theme", "client", "P",
          },
        },
        workspace = {
          preloadFileSize = 400,
        },
      },
    },
  },
  jdtls = {
    extra_setup = function()
      vim.api.nvim_exec([[
        augroup jdtls
        au!
        au FileType java lua require'jdtls'.start_or_attach({ cmd = { "/home/elianiva/.scripts/run_jdtls" }, on_attach = require'modules.lsp._mappings'.lsp_mappings("jdtls") })
        augroup END
      ]], false)
    end
  },
}

for name, opts in pairs(servers) do
  local client = nvim_lsp[name]
  if opts.extra_setup then
    opts.extra_setup()
  end
  client.setup({
    cmd = opts.cmd or client.cmd,
    filetypes = opts.filetypes or client.filetypes,
    on_attach = opts.on_attach or custom_on_attach,
    on_init = opts.on_init or custom_on_init,
    handlers = opts.handlers or client.handlers,
    root_dir = opts.root_dir or client.root_dir,
    capabilities = opts.capabilities or custom_capabilities(),
    settings = opts.settings or {},
  })
end

-- Flutter stuff
require("flutter-tools").setup {
  experimental = { -- map of feature flags
    lsp_derive_paths = false, -- experimental: Attempt to find the user's flutter SDK
  },
  debugger = { -- experimental: integrate with nvim dap
    enabled = false,
  },
  flutter_path = os.getenv("HOME") .. "/dev/android/flutter/bin/flutter", -- <-- this takes priority over the lookup
  widget_guides = {
    enabled = true,
  },
  closing_tags = {
    highlight = "Comment", -- highlight for the closing tag
    prefix = "// " -- character to use for close tag e.g. > Widget
  },
  dev_log = {
    open_cmd = "tabedit", -- command to use to open the log buffer
  },
  outline = {
    open_cmd = "30vnew", -- command to use to open the outline buffer
  },
  lsp = {
    on_attach = custom_on_attach,
    settings = {
      showTodos = true,
      -- completeFunctionCalls = true -- NOTE: this is WIP and doesn't work currently
    }
  }
}

-- Rust stuff
require("rust-tools").setup {
  tools = {
    inlay_hints = {
      show_parameter_hints = true,
      parameter_hints_prefix = "  <- ",
      other_hints_prefix = "  => ",
    },
    hover_actions = {
      border = Util.borders
    }
  },
  server = {
    on_attach = custom_on_attach,
    capabilities = (function()
      -- for autoimports
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          'documentation',
          'detail',
          'additionalTextEdits',
        }
      }
      return capabilities
    end)()
  }
}