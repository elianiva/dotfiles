local sumneko_root = os.getenv "HOME" .. "/Repos/lua-language-server"
local library = {}
local M = {}

local add = function(lib)
  for _, p in pairs(vim.fn.expand(lib, false, true)) do
    p = vim.loop.fs_realpath(p)
    library[p] = true
  end
end

-- add libraris to get detected by sumneko_lua
add "$VIMRUNTIME"
add "~/.config/nvim"

M.config = {
  cmd = {
    sumneko_root .. "/bin/Linux/lua-language-server",
    "-E",
    sumneko_root .. "/main.lua",
  },
  on_attach = Util.lsp_on_attach,
  on_init = Util.lsp_on_init,
  on_new_config = function(config, root)
    local libs = vim.tbl_deep_extend("force", {}, library)
    libs[root] = nil
    config.settings.Lua.workspace.library = libs
    return config
  end,
  settings = {
    Lua = {
      completion = {
        enable = true,
        callSnippet = "Replace",
      },
      runtime = {
        version = "LuaJIT",
        path = (function()
          local path = vim.split(package.path, ";")
          table.insert(path, "lua/?.lua")
          table.insert(path, "lua/?/init.lua")
          return path
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
        library = library,
      },
    },
  },
}

return M
