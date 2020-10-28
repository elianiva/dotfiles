local remap = vim.api.nvim_set_keymap

local prettier = {
  { cmd = { "prettier -w" } }
}

require'format'.setup {
  javascript = prettier,
  typescript = prettier,
  svelte = prettier,
  html = prettier,
  css = prettier,
}
remap('n', 'gf', '<cmd>FormatWrite<CR>', { noremap = true, silent = true })

vim.cmd('augroup Format')
vim.cmd('au!')
vim.cmd('au BufWritePost * FormatWrite')
vim.cmd('augroup END')
