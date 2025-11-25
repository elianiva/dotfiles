local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Set current working directory to file's directory on VimEnter
augroup("set_cwd", { clear = true })
autocmd("VimEnter", {
  desc = "Set current cwd",
  pattern = "*",
  callback = function()
    vim.cmd("cd %:p:h")
  end,
})

-- Start insert mode when entering terminal buffers
augroup("terminal", { clear = true })
autocmd("BufEnter", {
  desc = "Start insert on terminal",
  pattern = "term://*",
  command = "startinsert",
})

-- File type associations
augroup("filetypes", { clear = true })
autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Assign mdx to markdown",
  pattern = "*.mdx",
  command = "set ft=markdown",
})

-- Whitespace management
augroup("strip_whitespace", { clear = true })
autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  pattern = "*",
  callback = function()
    if vim.g.STRIP then
      vim.cmd("%s/\\s\\+$//e")
    end
  end,
})

-- Visual feedback
augroup("hl_on_yank", { clear = true })
autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 250, higroup = "Visual" })
  end,
})

