local remap = vim.api.nvim_set_keymap

local prettier = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
  }
end

-- formatting
require'format'.setup{
  javascript = { prettier = prettier },
  typescript = { prettier = prettier },
  svelte = { prettier = prettier },
  html = { prettier = prettier },
  css = { prettier = prettier },
}
remap('n', 'gf', '<cmd>Format<CR>', { noremap = true, silent = true })
