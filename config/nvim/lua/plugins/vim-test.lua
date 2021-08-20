local noremap = function(lhs, rhs)
  vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true })
end
noremap("<Leader>tn", "<CMD>TestNearest<CR>")
noremap("<Leader>tf", "<CMD>TestFile<CR>")
noremap("<Leader>ts", "<CMD>TestSuite<CR>")
noremap("<Leader>tl", "<CMD>TestLast<CR>")
noremap("<Leader>tg", "<CMD>TestVisit<CR>")

vim.g["test#strategy"] = "neovim"
