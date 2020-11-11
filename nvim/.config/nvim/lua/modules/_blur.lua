-- TODO: currently it causes massive lag when used against LSP
Blur = {}

-- blur the window
Blur.on = function()
  if not vim.bo.buflisted then return nil end

  local winhighlight_blurred = table.concat({
    'CursorLineNr:LineNr',
    'EndOfBuffer:ColorColumn',
    'IncSearch:ColorColumn',
    'Normal:ColorColumn',
    'NormalNC:ColorColumn',
    'SignColumn:ColorColumn'
  }, ',')

  vim.wo.winhighlight = winhighlight_blurred
  vim.cmd('setlocal syntax=off')
end

-- unblur the window
Blur.off = function()
  if not vim.bo.buflisted then return nil end

  vim.wo.winhighlight = ''
  vim.cmd('setlocal syntax=on')
end

-- apply colours
vim.cmd('augroup BlurWindow')
vim.cmd('au!')
vim.cmd('au WinEnter,BufEnter * call v:lua.Blur.off()')
vim.cmd('au WinLeave,BufLeave * call v:lua.Blur.on()')
vim.cmd('augroup END')
