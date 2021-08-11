-- vim: foldmethod=marker

local remap = vim.api.nvim_set_keymap
local cmp = require "cmp"

require("cmp_nvim_lsp").setup()

cmp.setup {
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
    ["<TAB>"] = cmp.mapping.item.next(),
    ["<S-TAB>"] = cmp.mapping.item.prev(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
  },
}

remap(
  "i",
  "<CR>",
  "v:lua.Util.trigger_completion()",
  { noremap = true, expr = true }
)
