vim.cmd[[packadd vim-vsnip]]

local remap = vim.api.nvim_set_keymap

remap('i', '<C-j>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"', { silent = true, expr = true })
remap('s', '<C-j>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<C-j>"', { silent = true, expr = true })
remap('i', '<C-k>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"', { silent = true, expr = true })
remap('s', '<C-k>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<C-k>"', { silent = true, expr = true })
