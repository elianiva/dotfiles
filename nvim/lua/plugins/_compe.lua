local remap = vim.api.nvim_set_keymap

require("compe").setup({
  enabled              = true,
  debug                = false,
  min_length           = 2,
  preselect            = "disable",
  source_timeout       = 200,
  incomplete_delay     = 400,
  throttle_time        = 200,
  allow_prefix_unmatch = true,

  source = {
    path     = true,
    buffer   = true,
    luasnip  = true,
    nvim_lua = true,
    nvim_lsp = {
      enable = true,
      priority = 10001, -- takes precedence over file completion
    },
  },
})

remap(
  "i",
  "<CR>",
  "v:lua.Util.trigger_completion()",
  { expr = true, silent = true }
)
remap(
  "i",
  "<Tab>",
  table.concat({
    "pumvisible() ? \"<C-n>\" : v:lua.Util.check_backspace()",
    "? \"<Tab>\" : compe#confirm()",
  }),
  { silent = true, noremap = true, expr = true }
)

remap(
  "i",
  "<S-Tab>",
  "pumvisible() ? \"<C-p>\" : \"<S-Tab>\"",
  { noremap = true, expr = true }
)
remap(
  "i",
  "<C-Space>",
  "compe#complete()",
  { noremap = true, expr = true, silent = true }
)

-- TODO(elianiva): REVISIT THIS LATER
-- inoremap{'<CR>', function() return Util.trigger_completion() end, { silent = true }}
--
-- local f = function(cmd)
--   return vim.api.nvim_feedkeys(
--     vim.api.nvim_replace_termcodes(cmd, true, true, true), 'n', true
--   )
-- end
--
-- inoremap{'<Tab>', function()
--   if vim.fn.pumvisible ~= 0 then return f('<C-n>') end
--   if Util.check_backspace() then return f('<Tab>') end
--   return f(vim.fn['compe#confirm']())
-- end, { silent = true }}
--
-- inoremap{'<S-Tab>', function()
--   if vim.fn.pumvisible ~= 0 then return f('<C-p>') end
--   return f('<S-Tab>')
-- end, { silent = true }}
--
-- inoremap{'<C-Space>', require"compe"._complete, { silent = true }}
