require("hop").setup()

vim.keymap.set("n", "<Leader>w", "<CMD>HopWord<CR>", {
  noremap = true,
  silent = true,
})
