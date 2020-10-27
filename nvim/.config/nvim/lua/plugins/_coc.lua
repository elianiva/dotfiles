local remap = vim.api.nvim_set_keymap

vim.g.coc_global_extensions = {
  'coc-eslint',
  'coc-tslint-plugin',
  'coc-json',
  'coc-css',
  'coc-html',
  'coc-stylelint',
  'coc-tsserver',
  'coc-svelte',
  'coc-snippets',
}

vim.g.coc_snippet_next = '<C-j>'
vim.g.coc_snippet_prev = '<C-k>'

vim.g.coc_root_patterns = { '.git', '.env', 'package.json' }

remap('i', '<Tab>', 'pumvisible() ? "<C-n>" : v:lua.check_backspace() ? "<Tab>" : coc#refresh()', { noremap = true, silent = true, expr = true })
remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })
remap('i', '<CR>', 'pumvisible() ? coc#_select_confirm() : "<C-g>u<CR><C-r>=coc#on_enter()<CR>"', { noremap = true, silent = true, expr = true })
remap('i', '<C-c>', 'coc#refresh()', { noremap = true, silent = true, expr = true })
remap('n', 'K', '<CMD>call CocActionAsync("doHover")<CR>', { noremap = true, silent = true })

remap('n', 'gd', '<Plug>(coc-definition)', {noremap = true, silent = true})
remap('n', 'gr', '<Plug>(coc-references)', {noremap = true, silent = true})
remap('n', 'gR', '<Plug>(coc-rename)', {noremap = true, silent = true})
