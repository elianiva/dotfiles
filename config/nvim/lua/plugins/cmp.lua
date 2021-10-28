-- vim: foldmethod=marker

local remap = vim.api.nvim_set_keymap
local cmp = require "cmp"

cmp.setup {
  completion = {
    autocomplete = false,
  },
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  documentation = {
    border = "solid",
  },
  sources = {
    { name = "nvim_lsp", priority = 10 },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer", keyword_length = 4 },
  },
  mapping = {
    ["<S-TAB>"]   = cmp.mapping.select_prev_item { cmp.SelectBehavior.Select },
    ["<TAB>"]     = cmp.mapping.select_next_item { cmp.SelectBehavior.Select },
    ["<C-SPACE>"] = cmp.mapping.complete(),
    ["<C-E>"]     = cmp.mapping.close(),
    ["<CR>"]      = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select   = true,
    },
  },
  experimental = {
    native_menu = true
  }
}

remap(
  "i",
  "<CR>",
  "v:lua.Util.trigger_completion()",
  { noremap = true, expr = true }
)
