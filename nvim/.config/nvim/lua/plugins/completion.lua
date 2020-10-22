vim.g.completion_enable_auto_hover = 1
vim.g.completion_auto_change_source = 1
vim.g.completion_enable_auto_signature = 0
vim.g.completion_menu_length = 20
vim.g.completion_enable_auto_signature = 0
vim.g.completion_matching_strategy_list = {'exact', 'substring'}
vim.g.completion_auto_change_source = 1
vim.g.completion_timer_cycle = 200

-- define an chain complete list
vim.g.completion_chain_complete_list = {
  default = {
    { complete_items = { 'lsp', 'buffers' } },
    { mode = { '<c-p>' } },
    { mode = { '<c-n>' } }
  },
  string = {
    { complete_items = {'path'}, triggered_only = {'/'} },
  },
  comment = {},
}
