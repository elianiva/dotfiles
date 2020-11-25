local remap = vim.api.nvim_set_keymap

vim.g.compe_enabled = true
vim.g.compe_min_length = 1
vim.g.compe_auto_preselect = false
vim.g.compe_source_timeout = 200
vim.g.compe_incomplete_delay = 400

-- integrate lexima to compe-nvim
-- remap('i', '<CR>', "compe#confirm(lexima#expand('<LT>CR>', 'i'))", { noremap = true, expr = true })
remap('i', '<CR>', "compe#confirm('<CR>')", { noremap = true, expr = true })

require'compe_nvim_lsp'.attach() -- lsp completion source
require'compe':register_lua_source('buffer', require'compe_buffer') -- buffer completion source

-- don't know why this won't work if I call it from lua instead of doing this
vim.api.nvim_command('call compe#source#vim_bridge#register("path", compe_path#source#create())')
vim.api.nvim_command('call compe#source#vim_bridge#register("vsnip", compe_vsnip#source#create())')

-- override default mapping that conflicts with vim-lexima
-- vim.g.lexima_no_default_rules = 1
-- vim.call('lexima#set_default_rules')

remap(
  'i', '<CR>',
  table.concat{
  'pumvisible()',
  '? complete_info()["selected"] != "-1"',
  '? compe#confirm("<CR>")',
  -- '? compe#confirm(lexima#expand("<LT>CR>", "i"))',
  ': "<C-g>u<CR>"',
  -- ': "<C-g>u".lexima#expand("<LT>CR>", "i")',
  ': v:lua.Util.check_html_char() ? "<CR><ESC>O"',
  -- ': v:lua.Util.check_html_char() ? lexima#expand("<LT>CR>", "i")."<ESC>O"',
  ': "<CR>"'
  -- ': lexima#expand("<LT>CR>", "i")'
  },
  { silent = true, expr = true }
)

remap(
  'i', '<Tab>',
  'pumvisible() ? "<C-n>" : v:lua.Util.check_backspace() ? "<Tab>" : compe#confirm("<CR>")',
  -- 'pumvisible() ? "<C-n>" : v:lua.Util.check_backspace() ? "<Tab>" : compe#confirm(lexima#expand("<LT>CR>", "i"))',
  { silent = true, noremap = true, expr = true }
)
remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })

-- force completion menu to appear
remap('i', '<C-c>', '<Plug>(completion_trigger)', { noremap = false, silent = true })
