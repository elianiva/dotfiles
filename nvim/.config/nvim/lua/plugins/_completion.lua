vim.g.completion_enable_auto_hover = 1
vim.g.completion_auto_change_source = 1
vim.g.completion_enable_auto_signature = 0
vim.g.completion_matching_strategy_list = {'exact', 'substring'}
vim.g.completion_auto_change_source = 1
vim.g.completion_enable_auto_paren = 0
vim.g.completion_sorting = 'length'
vim.g.completion_enable_snippet = 'vim-vsnip'

-- define an chain complete list
vim.g.completion_chain_complete_list = {
  default = {
    { complete_items = { 'lsp' } },
    { complete_items = { 'buffers' } },
    { complete_items = { 'snippet' } },
    { mode = { '<c-p>' } },
    { mode = { '<c-n>' } }
  },
  string = {
    { complete_items = {'path'}, triggered_only = {'/'} },
  },
  comment = {
    { complete_items = { 'buffers' } },
  },
}

-- not really sure if this works or not
vim.g.completion_items_priority = {
  ['Method'] = 10,
  ['Field'] = 8,
  ['Function'] = 8,
  ['Variables'] = 7,
  ['Interfaces'] = 6,
  ['Constant'] = 6,
  ['Class'] = 6,
  ['Struct'] = 6,
  ['Keyword'] = 5,
  ['File']  = 2,
  ['Snippets']  = 1,
  ['Buffers']  = 0,
}

-- attach completion-nvim and diagnostic for every filetype
vim.cmd('au BufEnter * lua require"completion".on_attach()')
