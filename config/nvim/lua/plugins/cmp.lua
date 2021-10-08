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
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
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
    -- ghost_text = true,
    native_menu = true, -- I don't use autocompletion anyway
  },
}

remap(
  "i",
  "<CR>",
  "v:lua.Util.trigger_completion()",
  { noremap = true, expr = true }
)
