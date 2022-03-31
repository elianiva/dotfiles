require("colorizer").setup {
  ["*"] = {
    css = true,
    css_fn = true,
    mode = "background",
  },
}

vim.keymap.set("n", "<leader>c", "<CMD>ColorizerToggle<CR>", {
  silent = true
});
