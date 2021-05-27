local dap = require("dap")

require("modules.dap._mappings")
require("modules.dap._ui")

-- in your init.lua (or copy the lines with command! in your init.vim)
vim.cmd [[
  command! -complete=file -nargs=* DebugC lua require "modules.dap._c_debugger".start_c_debugger({<f-args>}, "gdb")
]]
vim.cmd [[
  command! -complete=file -nargs=* DebugRust lua require "modules.dap._c_debugger".start_c_debugger({<f-args>}, "lldb", "rust-lldb")
]]


dap.adapters.node2 = {
  type = "executable",
  command = "node",
  args = {
    vim.env.HOME .. "/repos/vscode-node-debug2/out/src/nodeDebug.js",
  },
}

dap.adapters.rust = {
  type = "executable",
  attach = {
    pidProperty = "pid",
    pidSelect = "ask",
  },
  command = "lldb-vscode",
  env = {
    LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES",
  },
  name = "lldb",
}

dap.configurations.javascript = {
  {
    type = "node2",
    request = "launch",
    program = "${workspaceFolder}/${file}",
    cwd = vim.loop.cwd(),
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
  },
}

dap.configurations.rust = {
  {
    type = "node2",
    request = "launch",
    program = "${workspaceFolder}/${file}",
    cwd = vim.loop.cwd(),
    sourceMaps = true,
    protocol = "inspector",
    console = "integratedTerminal",
  },
}
