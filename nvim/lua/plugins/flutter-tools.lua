local M = {}

M.plugin = {
  "akinsho/flutter-tools.nvim",
  ft = "flutter",
  wants = {
    "nvim-lspconfig",
  },
  config = function()
    require("plugins.flutter-tools").config()
  end
}

M.config = function()
  require("flutter-tools").setup {
    experimental = { -- map of feature flags
      lsp_derive_paths = false, -- experimental: Attempt to find the user's flutter SDK
    },
    debugger = { -- experimental: integrate with nvim dap
      enabled = false,
    },
    flutter_path = os.getenv("HOME") .. "/dev/android/flutter/bin/flutter", -- <-- this takes priority over the lookup
    widget_guides = {
      enabled = true,
    },
    closing_tags = {
      highlight = "Comment", -- highlight for the closing tag
      prefix = "// ", -- character to use for close tag e.g. > Widget
    },
    dev_log = {
      open_cmd = "tabedit", -- command to use to open the log buffer
    },
    outline = {
      open_cmd = "30vnew", -- command to use to open the outline buffer
    },
    lsp = {
      on_attach = Util.lsp_on_attach,
      settings = {
        showTodos = true,
        -- completeFunctionCalls = true -- NOTE: this is WIP and doesn't work currently
      },
    },
  }
end

return M
