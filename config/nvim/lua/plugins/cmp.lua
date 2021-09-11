-- vim: foldmethod=marker

local remap = vim.api.nvim_set_keymap
local cmp = require "cmp"

cmp.setup {
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
    ["<S-TAB>"]   = cmp.mapping.select_prev_item(),
    ["<TAB>"]     = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]     = cmp.mapping.close(),
    ["<CR>"]      = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
  },
  -- experimental = {
  --   ghost_text = true,
  -- },
}

remap(
  "i",
  "<CR>",
  "v:lua.Util.trigger_completion()",
  { noremap = true, expr = true }
)