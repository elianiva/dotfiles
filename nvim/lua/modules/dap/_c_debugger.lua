local M = {}
local last_gdb_config

M.start_c_debugger = function(args, mi_mode, mi_debugger_path)
  local dap = require("dap")
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
    print("No binary to debug set! Use \":DebugC <binary> <args>\" or \":DebugRust <binary> <args>\"")
    return
  end

  dap.run(last_gdb_config)
  dap.repl.open()
end

return M
