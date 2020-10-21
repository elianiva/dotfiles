local remap = vim.api.nvim_set_keymap

vim.g.compe_enabled = true
vim.g.compe_min_length = 1
vim.g.compe_auto_preselect = false -- or v:false
vim.g.compe_source_timeout = 200
vim.g.compe_incomplete_delay = 400

remap(
  'i', '<Tab>',
  'pumvisible() ? "<C-n>" : v:lua.check_backspace() ? "<Tab>" : compe#complete()',
  { noremap = true, expr = true }
)

remap('i', '<CR>', "compe#confirm(lexima#expand('<LT>CR>', 'i'))", { noremap = true, expr = true })
remap('i', '<C-c>', '<C-r>=compe#complete()', { noremap = false, silent = true })
require'compe_nvim_lsp'.attach()
require'compe':register_lua_source('buffer', require'compe_buffer')
vim.api.nvim_eval("call compe#source#vim_bridge#register('path', compe_path#source#create())")
