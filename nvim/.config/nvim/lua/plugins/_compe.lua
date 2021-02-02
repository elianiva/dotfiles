vim.cmd[[packadd nvim-compe]]

local k = require"astronauta.keymap"
local inoremap = k.inoremap

local remap = vim.api.nvim_set_keymap

vim.g.vsnip_snippet_dir = vim.fn.stdpath("config").."/snippets"

require'compe'.setup {
  enabled = true,
  debug = false,
  min_length = 2,
  preselect = "disable",
  source_timeout = 200,
  incomplete_delay = 400,
  allow_prefix_unmatch = false,
  source = {
    spell = true,
    path = true,
    calc = true,
    buffer = true,
    vsnip = true,
    tags = true,
    nvim_lsp = true,
    nvim_lua = true,
  },
}

local npairs = require('nvim-autopairs')
Util.trigger_completion = function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"]()
    end

    vim.fn.nvim_select_popupmenu_item(0 , false , false ,{})
    P(vim.fn["compe#confirm"]())
    return vim.fn["compe#confirm"]()
  end

  return npairs.check_break_line_char()
end

remap('i', '<CR>', 'v:lua.Util.trigger_completion()', { expr = true, silent = true })
remap(
  'i', '<Tab>',
  table.concat{
    'pumvisible() ? "<C-n>" : v:lua.Util.check_backspace()',
    '? "<Tab>" : compe#confirm()',
  },
  { silent = true, noremap = true, expr = true }
)

remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })
remap('i', '<C-Space>', 'compe#complete()', { noremap = true, expr = true, silent = true })

-- TODO(elianiva): REVISIT THIS LATER
-- inoremap{'<CR>', function() return Util.trigger_completion() end, { silent = true }}
--
-- local f = function(cmd)
--   return vim.api.nvim_feedkeys(
--     vim.api.nvim_replace_termcodes(cmd, true, true, true), 'n', true
--   )
-- end
--
-- inoremap{'<Tab>', function()
--   if vim.fn.pumvisible ~= 0 then return f('<C-n>') end
--   if Util.check_backspace() then return f('<Tab>') end
--   return f(vim.fn['compe#confirm']())
-- end, { silent = true }}
--
-- inoremap{'<S-Tab>', function()
--   if vim.fn.pumvisible ~= 0 then return f('<C-p>') end
--   return f('<S-Tab>')
-- end, { silent = true }}
--
-- inoremap{'<C-Space>', function() return f(vim.fn["compe#complete"]()) end, { silent = true }}
