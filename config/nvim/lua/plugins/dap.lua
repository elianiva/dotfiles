local dap = require "dap"
local dapui = require "dapui"
local dap_go = require "dap-go"

local nnoremap = function(lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = true
  vim.keymap.set("n", lhs, rhs, opts)
end

dapui.setup()
dap_go.setup()

nnoremap("<F5>", dap.continue, {
  desc = "Continue the current debug session",
})
nnoremap("<F10>", dap.step_over, {
  desc = "Step over the current line",
})
nnoremap("<F11>", dap.step_into, {
  desc = "Step into the current line",
})
nnoremap("<F12>", dap.step_out, {
  desc = "Step out of the current function",
})
nnoremap("<Leader>du", dapui.toggle, {
  desc = "Toggle the DAP UI",
})
nnoremap("<Leader>db", dap.toggle_breakpoint, {
  desc = "Toggle a breakpoint on the current line",
})
nnoremap("<Leader>dt", dap.terminate, {
  desc = "Terminate the current debug session",
})
nnoremap("<Leader>dB", function()
  dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, {
  desc = "Set a breakpoint on the current line",
})

local signs = {
  Breakpoint = " ",
  BreakpointCondition = " ",
  LogPoint = " ",
  Stopped = " ",
  BreakpointRejected = " ",
}

for name, char in pairs(signs) do
  local hl = "Dap" .. name
  vim.fn.sign_define(hl, {
    text = char,
    texthl = hl,
    numhl = "",
  })
end
