return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  keys = {
    { '<leader>db', ':DBUIToggle<CR>', desc = "Toggle Dadbod UI" },
    { '<leader>dc', ':DBUIAddConnection<CR>', desc = "Add Dadbod Connection" },
    { '<leader>df', ':DBUIFindBuffer<CR>', desc = "Find Dadbod Buffer" },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
