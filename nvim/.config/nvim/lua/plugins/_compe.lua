vim.cmd [[packadd nvim-compe]]
local remap = vim.api.nvim_set_keymap

vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"

require("compe").setup({
  enabled              = true,
  debug                = false,
  min_length           = 2,
  preselect            = "disable",
  source_timeout       = 200,
  incomplete_delay     = 400,
  allow_prefix_unmatch = false,

  source = {
    path     = true,
    calc     = true,
    buffer   = true,
    vsnip    = true,
    nvim_lsp = true,
    nvim_lua = true,
  },
})

Util.trigger_completion = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"]()
    end
  end

  local prev_col, next_col = vim.fn.col(".") - 1, vim.fn.col(".")
  local prev_char = vim.fn.getline("."):sub(prev_col, prev_col)
  local next_char = vim.fn.getline("."):sub(next_col, next_col)

  -- minimal autopairs-like behaviour
  if prev_char == "{" and next_char == "" then return Util.t("<CR>}<C-o>O") end
  if prev_char == "[" and next_char == "" then return Util.t("<CR>]<C-o>O") end
  if prev_char == "(" and next_char == "" then return Util.t("<CR>)<C-o>O") end
  if prev_char == ">" and next_char == "<" then return Util.t("<CR><C-o>O") end -- html indents
  return Util.t("<CR>")
end

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
