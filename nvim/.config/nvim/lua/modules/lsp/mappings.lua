local remap = vim.api.nvim_set_keymap

check_backspace = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- lsp actions
remap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
remap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
remap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
remap('n', 'gD', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', { noremap = true, silent = true })
remap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
remap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
remap('n', 'gx', '<cmd>lua xdg_open()<CR>', { noremap = true, silent = true })

-- formatting
require'format'.setup{
  javascript = {
    prettier = function()
      return {
        exe = "prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
        stdin = true
      }
    end
  },
  svelte = {
    prettier = function()
      return {
        exe = "prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
        stdin = true
      }
    end
  },
  html = {
    prettier = function()
      return {
        exe = "prettier",
        args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
        stdin = true
      }
    end
  },
}
remap('n', 'gf', '<cmd>Format<CR>', { noremap = true, silent = true })

-- override default mapping that conflicts with vim-auto-pair
vim.g.completion_confirm_key = ""
remap(
  'i', '<CR>',
  -- 'pumvisible() ? complete_info()["selected"] != "-1" ? "<Plug>(completion_confirm_completion)"  : "<c-e><CR>" :  "<CR>"',
  'pumvisible() ? complete_info()["selected"] != "-1" ? "<Plug>(completion_confirm_completion)"  : "<C-g>u<CR>" :  "<CR>"',
  { noremap = true, expr = true }
)

remap(
  'i', '<Tab>',
  'pumvisible() ? "<C-n>" : v:lua.check_backspace() ? "<Tab>" : completion#trigger_completion()',
  { noremap = true, expr = true }
)

remap('i', '<S-Tab>', 'pumvisible() ? "<C-p>" : "<S-Tab>"', { noremap = true, expr = true })

-- force completion menu to appear
remap('i', '<C-c>', '<Plug>(completion_trigger)', { noremap = false, silent = true })
