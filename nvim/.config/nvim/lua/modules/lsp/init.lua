local nvim_lsp = require('nvim_lsp')
-- local nlua = require('nlua.lsp.nvim')
local diagnostic = require('diagnostic')
local remap = vim.api.nvim_set_keymap

require('modules.lsp._svelte')

local custom_on_attach = function()
  -- sweet diagnostics
  diagnostic.on_attach()

  -- lsp actions
  remap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
  remap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
  remap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
  remap('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, silent = true })
  remap('n', 'gD', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', { noremap = true, silent = true })
  -- remap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
  remap('n', 'gr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', { noremap = true, silent = true })
  remap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
end

local custom_on_init = function()
  print('Language Server Protocol started!')
end

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' },
  on_attach = custom_on_attach,
  on_init = custom_on_init,
  root_dir = function()
    return vim.loop.cwd()
  end
}

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

require('modules.lsp._settings')
require('modules.lsp._mappings')
require('modules.lsp._custom_callbacks')

-- attach completion-nvim and diagnostic for every filetype
vim.cmd('au BufEnter * lua require"completion".on_attach()')
