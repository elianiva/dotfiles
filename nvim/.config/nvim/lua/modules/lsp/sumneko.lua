-- local sumneko_root = os.getenv "HOME" .. "/Repos/lua-language-server"
local M = {}

M.config = {
  cmd = { "lua-language-server" },
  -- cmd = {
  --   sumneko_root .. "/bin/Linux/lua-language-server",
  --   "-E",
  --   sumneko_root .. "/main.lua",
  -- },
  on_attach = Util.lsp_on_attach,
  on_init = Util.lsp_on_init,
  settings = {
    Lua = {
      completion = {
        enable = true,
        callSnippet = "Replace",
        showWord = "Disable",
      },
      runtime = {
        version = "LuaJIT",
        path = (function()
          local runtime_path = vim.split(package.path, ";")
          table.insert(runtime_path, "lua/?.lua")
          table.insert(runtime_path, "lua/?/init.lua")
          return runtime_path
        end)(),
      },
      diagnostics = {
        enable = true,
        globals = {
          "vim",
          "describe",
          "it",
          "before_each",
          "after_each",
          "awesome",
          "theme",
          "client",
          "P",
        },
      },
      workspace = {
        preloadFileSize = 400,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
}

return M
