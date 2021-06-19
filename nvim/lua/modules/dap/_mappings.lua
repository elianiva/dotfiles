local k = vim.keymap
local nnoremap = k.nnoremap

local dap = require("dap")
local api = vim.api

local keymap_restore = {}

nnoremap { "<Leader>db", dap.toggle_breakpoint, { silent = true }}
nnoremap { "<Leader>dc", dap.continue, { silent = true }}
nnoremap { "<Leader>do", dap.step_over, { silent = true }}
nnoremap { "<Leader>d>", dap.step_into, { silent = true }}
nnoremap { "<Leader>d<", dap.step_out, { silent = true }}
nnoremap { "<Leader>dr", dap.repl.open, { silent = true }}

dap.listeners.after['event_initialized']['me'] = function()
  for _, buf in pairs(api.nvim_list_bufs()) do
    local keymaps = api.nvim_buf_get_keymap(buf, 'n')
    for _, keymap in pairs(keymaps) do
      if keymap.lhs == "K" then
        table.insert(keymap_restore, keymap)
        api.nvim_buf_del_keymap(buf, 'n', 'K')
      end
    end
  end
  api.nvim_set_keymap(
    'n',
    'K',
    '<Cmd>lua require("dap.ui.widgets").hover(nil, { border = Util.borders })<CR>', {
    silent = true,
  })
end

dap.listeners.after['event_terminated']['me'] = function()
  for _, keymap in pairs(keymap_restore) do
    api.nvim_buf_set_keymap(
      keymap.buffer,
      keymap.mode,
      keymap.lhs,
      keymap.rhs,
      { silent = keymap.silent == 1 }
    )
  end
  keymap_restore = {}
end
