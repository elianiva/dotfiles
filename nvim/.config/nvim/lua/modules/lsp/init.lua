local nvim_lsp = require('nvim_lsp')
local diagnostic = require('diagnostic')

require('modules.lsp.svelte')

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' };
  on_attach = function()
    print('tsserver started!')
    diagnostic.on_attach()
  end
}

nvim_lsp.html.setup{
  on_attach = function()
    print('html-language-server started!')
    diagnostic.on_attach()
  end
}

nvim_lsp.cssls.setup{
  on_attach = function()
    print('css-language-server started!')
    diagnostic.on_attach()
  end
}

nvim_lsp.svelte.setup{
  on_attach = function()
    print("svelte-language-server started!")
    diagnostic.on_attach()
  end
}

nvim_lsp.sumneko_lua.setup{
  on_attach = function()
    print("lua-language-server started!")
    diagnostic.on_attach()
  end
}

-- nvim_lsp.diagnosticls.setup{
--   filetypes = { 'typescript', 'javascript' },
--   init_options = {
--     linters = {
--       eslint = {
--         command = 'eslint',
--         rootPatterns = {'.git'},
--         debounce = 100,
--         args = {
--           '--stdin',
--           '--stdin-filename',
--           '%filepath',
--           '--format',
--           'json'
--         },
--         sourceName = 'eslint',
--         parseJson = {
--           errorsRoot = '[0].messages',
--           line = 'line',
--           column = 'column',
--           endLine = 'endLine',
--           endColumn = 'endColumn',
--           message = '${message} [${ruleId}]',
--           security = 'severity'
--         },
--         securities = {
--           [2] = 'error',
--           [1] = 'warning',
--         },
--       },
--     },
--     filetypes = {
--       javascript = 'eslint',
--       typescript = 'eslint'
--     },
--     formatters = {
--       prettier = {
--         command = "prettier",
--         args = {"--stdin-filepath" ,"%filepath", "--no-semicolon"}
--       }
--     },
--     formatFiletypes = {
--       javascript = "prettier",
--       typescript = "prettier",
--     },
--   }
-- }

require('modules.lsp.settings')
require('modules.lsp.mappings')

-- attach completion-nvim and diagnostic for every filetype
vim.cmd('au BufEnter * lua require"completion".on_attach()')
