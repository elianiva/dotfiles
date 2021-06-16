local dap = require("dap")
local M = {}
local last_gdb_config

M.gdb = function(args, mi_mode, mi_debugger_path)
  if args and #args > 0 then
    last_gdb_config = {
      type = "rust",
      name = args[1],
      request = "launch",
      program = table.remove(args, 1),
      args = args,
      cwd = vim.loop.cwd(),
      externalConsole = true,
      MIMode = mi_mode,
      MIDebuggerPath = mi_debugger_path,
    }
  end

  if not last_gdb_config then
    print 'No binary to debug set! Use ":DebugC <binary> <args>" or ":DebugRust <binary> <args>"'
    return
  end

  dap.run(last_gdb_config)
end

M.node = function()
  print("Attaching Node Debugger...")
  dap.run {
    type = "node2",
    request = "attach",
    cwd = vim.loop.cwd(),
    sourceMaps = true,
    protocol = "inspector",
    skipFiles = { "<node_internals>/**/*.js" },
  }
  print("Attached!")
end

return M
