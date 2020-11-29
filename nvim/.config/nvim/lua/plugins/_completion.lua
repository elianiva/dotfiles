local remap = vim.api.nvim_set_keymap
local cmd = vim.api.nvim_command

-- compe settings
vim.g.compe_enabled = true
vim.g.compe_min_length = 2
vim.g.compe_auto_preselect = false
vim.g.compe_source_timeout = 200
vim.g.compe_incomplete_delay = 400

-- lsp completion source
require'compe_nvim_lsp'.attach()

-- buffer completion source
require'compe':register_lua_source('buffer', require'compe_buffer')

-- must be called from vimL because it returns funcref which doesn't supported yet(?) in Lua
cmd('call compe#source#vim_bridge#register("path", compe_path#source#create())')
cmd('call compe#source#vim_bridge#register("vsnip", compe_vsnip#source#create())')

vim.g.lexima_no_default_rules = 1
vim.fn['lexima#set_default_rules']()

-- check prev character, depending on previous char
-- it will do special stuff or just `<CR>`
-- i.e: accept completion item, indent html, autoindent braces/etc, just enter
remap(
  'i', '<CR>',
  table.concat{
  'pumvisible()',
  '? complete_info()["selected"] != "-1"',
  '? compe#confirm(lexima#expand("<LT>CR>", "i"))',
  ': "<C-g>u".lexima#expand("<LT>CR>", "i")',
  ': v:lua.Util.check_html_char() ? lexima#expand("<LT>CR>", "i")."<ESC>O"',
  ': lexima#expand("<LT>CR>", "i")'
  },
  { silent = true, expr = true }
)

-- cycle tab or insert tab depending on prev char
remap(
  'i', '<Tab>',
  'pumvisible() ? "<C-n>" : v:lua.Util.check_backspace() ? "<Tab>" : compe#confirm(lexima#expand("<LT>CR>", "i"))',
  { silent = true, noremap = true, expr = true }
)
remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })
