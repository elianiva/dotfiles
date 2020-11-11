Util = {}

Util.check_backspace = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

Util.check_html_char = function()
  local prev_col = vim.fn.col('.') - 1
  local next_col = vim.fn.col('.')
  local prev_char = vim.fn.getline('.'):sub(prev_col, prev_col)
  local next_char = vim.fn.getline('.'):sub(next_col, next_col)

  if prev_char:match('>') and next_char:match('<') then
    return true
  else
    return false
  end
end

-- preview file using xdg_open
Util.xdg_open = function()
  local filename = vim.fn.expand('<cfile>')
  vim.loop.spawn('xdg-open', { args = { filename } })
end
