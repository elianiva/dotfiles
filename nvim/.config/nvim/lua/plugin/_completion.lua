vim.cmd[[packadd nvim-compe]]
vim.cmd[[packadd vim-vsnip]]
vim.cmd[[packadd vim-vsnip-integ]]

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

local npairs = require('nvim-autopairs')
Util.trigger_completion = function()
  if vim.fn.pumvisible() ~= 0  then

    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-y>")
    end

    vim.fn.nvim_select_popupmenu_item(0 , false , false ,{})
    vim.fn["compe#confirm"]()

    return npairs.esc("<c-n><c-y>")
  end

  return npairs.check_break_line_char()
end

remap('i', '<CR>', 'v:lua.Util.trigger_completion()', { expr = true, silent = true })

-- cycle tab or insert tab depending on prev char
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
