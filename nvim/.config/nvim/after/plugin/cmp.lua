-- vim: foldmethod=marker

-- local map = vim.keymap.set
-- local cmp = require "cmp"

-- cmp.setup {
--   completion = {
--     autocomplete = false,
--   },
--   preselect = cmp.PreselectMode.None,
--   snippet = {
--     expand = function(args)
--       vim.fn["vsnip#anonymous"](args.body)
--     end,
--   },
--   documentation = {
--     border = "solid",
--   },
--   sources = {
--     { name = "nvim_lsp", priority = 10 },
--     { name = "vsnip" },
--     { name = "path" },
--     { name = "buffer", keyword_length = 8 },
--   },
--   mapping = {
--     ["<Tab>"] = cmp.mapping.select_next_item { cmp.SelectBehavior.Select },
--     ["<S-Tab>"] = cmp.mapping.select_prev_item { cmp.SelectBehavior.Select },
--     ["<C-Space>"] = cmp.mapping.complete(),
--     ["<C-d>"] = cmp.mapping.scroll_docs(4),
--     ["<C-u>"] = cmp.mapping.scroll_docs(-4),
--     ["<C-e>"] = cmp.mapping.close(),
--     ["<CR>"] = cmp.mapping.confirm {
--       behavior = cmp.ConfirmBehavior.Replace,
--       select = true,
--     },
--   },
-- }

-- local fn = vim.fn
-- local trigger_completion = function()
--   local prev_col, next_col = fn.col "." - 1, fn.col "."
--   local prev_char = fn.getline("."):sub(prev_col, prev_col)
--   local next_char = fn.getline("."):sub(next_col, next_col)

--   -- minimal autopairs-like behaviour

--   -- stylua: ignore start
--   if prev_char == "{" and next_char ~= "}" then return "<CR>}<C-o>O" end
--   if prev_char == "[" and next_char ~= "]" then return "<CR>]<C-o>O" end
--   if prev_char == "(" and next_char ~= ")" then return "<CR>)<C-o>O" end
--   if prev_char == ">" and next_char == "<" then return "<CR><C-o>O" end -- html indents
--   if prev_char == "(" and next_char == ")" then return "<CR><C-o>O" end -- flutter indents
--   -- stylua: ignore end

--   return "<CR>"
-- end

-- map("i", "<CR>", trigger_completion, { expr = true })
