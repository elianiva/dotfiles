local noremap = function(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, { noremap = true })
end

noremap("<Leader>tn", function()
  if vim.bo.filetype == "go" then
    require("dap-go").debug_test()
  else
    vim.cmd [[<CMD>TestNearest<CR>]]
  end
end)
noremap("<Leader>tf", "<CMD>TestFile<CR>")
noremap("<Leader>ts", "<CMD>TestSuite<CR>")
noremap("<Leader>tl", "<CMD>TestLast<CR>")
noremap("<Leader>tg", "<CMD>TestVisit<CR>")

vim.g["test#strategy"] = "neovim"
