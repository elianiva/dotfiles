require("config.lazy")
require("config.options")
require("config.mappings")
require("config.lsp")

vim.o.shell = "/run/current-system/sw/bin/bash"

-- prevent typo when pressing `wq` or `q`
vim.cmd([[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]])

-- for some reason vim-zig adds autoformatting on save
vim.g.zig_fmt_autosave = false

vim.diagnostic.config({
  virtual_lines = false,
  float = {
    border = "single",
    severity_sort = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})


vim.api.nvim_create_autocmd({ "VimEnter" }, {
  desc = "Set current cwd",
  pattern = { "*" },
  command = "cd %:p:h",
})

vim.api.nvim_create_autocmd({ "Bufenter" }, {
  desc = "Start insert on terminal",
  pattern = { "term://*" },
  command = "startinsert",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Assign mdx to markdown",
  pattern = { "*.mdx" },
  command = "set ft=markdown",
})

vim.g.STRIP = true -- to temporarily disable
vim.api.nvim_create_augroup("strip_whitespace", {
  clear = true
})
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  desc = "Remove trailing whitespace on save",
  group = "strip_whitespace",
  pattern = { "*" },
  callback = function()
    if vim.g.STRIP then
      vim.cmd("%s/\\s\\+$//e")
    end
  end,
})

vim.api.nvim_create_augroup("hl_on_yank", {
  clear = true
})
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  desc = "Highlight yanked text",
  group = "hl_on_yank",
  pattern = { "*" },
  callback = function()
    vim.highlight.on_yank { timeout = 250, higroup = "Visual" }
  end
})
