vim.cmd[[packadd nvim-compe]]
vim.cmd[[packadd nvim-autopairs]]
vim.cmd[[packadd vim-vsnip]]
vim.cmd[[packadd vim-vsnip-integ]]
-- vim.cmd[[packadd lexima.vim]]

local remap = vim.api.nvim_set_keymap

vim.g.vsnip_snippet_dir = vim.fn.stdpath("config").."/snippets"

require'compe'.setup {
  enabled = true;
  debug = false;
  min_length = 2;
  preselect = "disable";
  source_timeout = 200;
  incomplete_delay = 400;
  allow_prefix_unmatch = false;
  source = {
    path = true;
    buffer = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
  };
}

-- -- needs to be here, otherwise `check_html_char` wouldn't work
-- vim.g.no_default_rules = 1
-- vim.g.lexima_accept_pum_with_enter = 1
-- vim.fn["lexima#set_default_rules"]()

local npairs = require('nvim-autopairs')

npairs.setup{
  break_line_filetype = {'javascript' , 'typescript' , 'typescriptreact' , 'go', 'lua'}
}

Util.trigger_completion = function()
  if vim.fn.pumvisible() ~= 0  then

    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-y>")
    end

    vim.fn.nvim_select_popupmenu_item(0 , false , false ,{})
    vim.fn["compe#confirm"]()

    return npairs.esc("<c-n><c-y>")
  else
    return npairs.check_break_line_char()
  end
  return npairs.esc("<cr>")
end

remap('i', '<CR>', 'v:lua.Util.trigger_completion()', { expr = true, silent = true })

-- -- check prev character, depending on previous char
-- -- it will do special stuff or just `<CR>`
-- -- i.e: accept completion item, indent html, autoindent braces/etc, just enter
-- remap(
--   'i', '<CR>',
--   table.concat{
--     'pumvisible()',
--     '? complete_info()["selected"] != "-1"',
--     '? compe#confirm(lexima#expand("<LT>CR>", "i"))',
--     ': "<C-g>u".lexima#expand("<LT>CR>", "i")',
--     ': v:lua.Util.check_html_char() ? lexima#expand("<LT>CR>", "i")."<ESC>O"',
--     ': lexima#expand("<LT>CR>", "i")'
--   },
--   { silent = true, expr = true }
-- )

-- cycle tab or insert tab depending on prev char
remap(
  'i', '<Tab>',
  table.concat{
    'pumvisible() ? "<C-n>" : v:lua.Util.check_backspace()',
    -- '? "<Tab>" : compe#confirm(lexima#expand("<LT>CR>", "i"))',
    '? "<Tab>" : compe#confirm()',
  },
  { silent = true, noremap = true, expr = true }
)

remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })
remap('i', '<C-Space>', 'compe#complete()', { noremap = true, expr = true, silent = true })
