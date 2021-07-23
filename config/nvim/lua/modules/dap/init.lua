local dap = require "dap"

require "modules.dap.mappings"
-- require("modules.dap.ui")

vim.fn.sign_define("DapBreakpoint", {
  text = "🛑",
  texthl = "LspDiagnosticsDefaultError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "",
  texthl = "",
  linehl = "",
  numhl = "",
})

vim.cmd [[
  command! -complete=file -nargs=* DebugC lua require "modules.dap.custom_launch".c_debug({<f-args>}, "gdb")
  command! -complete=file -nargs=* DebugRust lua require "modules.dap.custom_launch".c_debug({<f-args>}, "lldb", "rust-lldb")
  command! -complete=file -nargs=* DebugNode lua require "modules.dap.custom_launch".node()
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

dap.adapters.go = function(callback)
  local handle
  local port = 38697
  handle = vim.loop.spawn("dlv", {
    args = { "dap", "-l", "127.0.0.1:" .. port },
    detached = true,
  }, function(code)
    handle:close()
    print("Delve exited with exit code: " .. code)
  end)
  -- Wait 100ms for delve to start
  vim.defer_fn(function()
    --dap.repl.open()
    callback { type = "server", host = "127.0.0.1", port = port }
  end, 100)
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  {
    type = "go",
    name = "Debug",
    request = "launch",
    program = "${file}",
  },
  {
    type = "go",
    name = "Debug test", -- configuration for debugging test files
    request = "launch",
    mode = "test",
    program = "${file}",
  },
}

require("dap.ext.vscode").load_launchjs()
