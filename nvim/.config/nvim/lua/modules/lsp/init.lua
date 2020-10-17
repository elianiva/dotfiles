local nvim_lsp = require('nvim_lsp')

require('modules.lsp.svelte')

nvim_lsp.tsserver.setup{
  filetypes = { 'javascript', 'typescript', 'typescriptreact' };
  on_attach = function(client, bufnr)
    print('tsserver started!')
  end
}

nvim_lsp.html.setup{
  on_attach = function(client, bufnr)
    print('html-language-server started!')
  end
}

nvim_lsp.cssls.setup{
  on_attach = function(client, bufnr)
    print('css-language-server started!')
  end
}

nvim_lsp.svelte.setup{
  on_attach = function(client, bufnr)
    print("svelte-language-server started!")
  end
}

nvim_lsp.sumneko_lua.setup{
  on_attach = function(client, bufnr)
    print("lua-language-server started!")
  end
}

require('modules.lsp.settings')
require('modules.lsp.mappings')

-- attach completion-nvim and diagnostic for every filetype
vim.cmd('au BufEnter * lua require"diagnostic".on_attach()')
vim.cmd('au BufEnter * lua require"completion".on_attach()')
