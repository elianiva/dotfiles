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

-- nvim_lsp.sumneko_lua.setup{
--   on_attach = function()
--     print("lua-language-server started!")
--     diagnostic.on_attach()
--   end
-- }

require'nlua.lsp.nvim'.setup(nvim_lsp, {
  -- include globals you want to tell the LSP are real
  globals = {
    "vim", -- vim
    "awesome", "theme", "root", -- awesomewm
  }
})

require('modules.lsp.settings')
require('modules.lsp.mappings')

-- attach completion-nvim and diagnostic for every filetype
vim.cmd('au BufEnter * lua require"completion".on_attach()')
