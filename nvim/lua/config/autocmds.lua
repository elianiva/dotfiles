local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Set current working directory to file's directory on VimEnter
local set_cwd_group = augroup("set_cwd", { clear = true })
autocmd("VimEnter", {
  desc = "Set current cwd",
  pattern = "*",
  callback = function()
    vim.cmd("cd %:p:h")
  end,
  group = set_cwd_group,
})

-- Start insert mode when entering terminal buffers
local terminal_group = augroup("terminal", { clear = true })
autocmd("BufEnter", {
  desc = "Start insert on terminal",
  pattern = "term://*",
  callback = function()
    -- Skip during startup
    if vim.v.vim_did_init == 0 then
      return
    end
    vim.cmd("startinsert")
  end,
  group = terminal_group,
})

-- File type associations
local filetypes_group = augroup("filetypes", { clear = true })
autocmd({ "BufNewFile", "BufRead" }, {
  desc = "Assign mdx to markdown",
  pattern = "*.mdx",
  command = "set ft=markdown",
  group = filetypes_group,
})

-- Whitespace management
local strip_whitespace_group = augroup("strip_whitespace", { clear = true })
autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  pattern = "*",
  callback = function()
    if vim.g.STRIP then
      vim.cmd("%s/\\s\\+$//e")
    end
  end,
  group = strip_whitespace_group,
})

-- Visual feedback
local hl_on_yank_group = augroup("hl_on_yank", { clear = true })
autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 250, higroup = "Visual" })
  end,
  group = hl_on_yank_group,
})

-- Auto-create missing directories on save
local auto_mkdir_group = augroup("auto_mkdir", { clear = true })
autocmd("BufWritePre", {
  desc = "Create missing directories",
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local dir = vim.fn.fnamemodify(event.match, ":p:h")
    vim.fn.mkdir(dir, "p")
  end,
  group = auto_mkdir_group,
})

-- Auto-close quickfix when it's the last window
local qf_close_group = augroup("qf_close", { clear = true })
autocmd("WinEnter", {
  desc = "Auto close quickfix",
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
      vim.cmd.quit()
    end
  end,
  group = qf_close_group,
})
