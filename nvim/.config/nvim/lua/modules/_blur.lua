-- TODO: currently it causes massive lag when used against LSP
local winhighlight_blurred = table.concat({
  'CursorLineNr:LineNr',
  'EndOfBuffer:ColorColumn',
  'IncSearch:ColorColumn',
  'Normal:ColorColumn',
  'NormalNC:ColorColumn',
  'SignColumn:ColorColumn'
}, ',')

-- blur the window
blur_window = function()
  if not vim.bo.buflisted then return nil end

  vim.wo.winhighlight = winhighlight_blurred
  vim.cmd('setlocal syntax=off')
end

-- unblur the window
unblur_window = function()
  if not vim.bo.buflisted then return nil end

  vim.wo.winhighlight = ''
  vim.cmd('setlocal syntax=on')
end

-- apply colours
vim.cmd('augroup BlurWindow')
vim.cmd('au!')
vim.cmd('au WinEnter,BufEnter * call v:lua.unblur_window()')
vim.cmd('au WinLeave,BufLeave * call v:lua.blur_window()')
vim.cmd('augroup END')

