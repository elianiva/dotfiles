local remap = vim.api.nvim_set_keymap

local prettier = {
  {
    cmd = {
      function(file)
        return string.format("prettier -w --config %s/.prettierrc %s", vim.fn.getcwd(), file)
      end
    },
    tempfile_dir = os.getenv("HOME").."/.config/nvim"
  }
}

require'format'.setup {
  javascript = prettier,
  typescript = prettier,
  svelte = prettier,
  html = prettier,
  css = prettier,
}
remap('n', 'gf', '<cmd>FormatWrite<CR>', { noremap = true, silent = true })

-- vim.cmd('augroup Format')
-- vim.cmd('au!')
-- vim.cmd('au BufWritePost * FormatWrite')
-- vim.cmd('augroup END')
