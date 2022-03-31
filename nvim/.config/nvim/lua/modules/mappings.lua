local u = require "modules.util"
local noremap = u.noremap
local nnoremap = u.nnoremap
local inoremap = u.inoremap
local tnoremap = u.tnoremap
local vnoremap = u.vnoremap

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
noremap("n", '"Nn"[v:searchforward]', {
  expr = true,
  desc = "Better forward N behaviour",
})
noremap("N", '"nN"[v:searchforward]', {
  expr = true,
  desc = "Better backward N behaviour",
})

-- stolen from justinmk
nnoremap("/", "ms/", { desc = "Keeps jumplist after forward searching" })
nnoremap("?", "ms?", { desc = "Keeps jumplist after backward searching" })

nnoremap("<C-n>", "<CMD>NeoTreeRevealToggle<CR>", { desc = "Toggle NeoTree" })

-- TERMINAL MAPPINGS
tnoremap("<C-h>", "<C-\\><C-n><C-w><C-h>", {
  desc = "Move to the left of the terminal",
})
-- tnoremap("<C-l>", "<C-\\><C-n><C-w><C-l>", {
--   desc = "Move to the right of the terminal",
-- })
tnoremap("<C-j>", "<C-\\><C-n><C-w><C-j>", {
  desc = "Move to the bottom of the terminal",
})
tnoremap("<C-k>", "<C-\\><C-n><C-w><C-k>", {
  desc = "Move to the top of the terminal",
})
tnoremap("<Left>", "<C-\\><C-n>:vertical resize +2<CR>", {
  desc = "Resize terminal window to the left (+2)",
})
tnoremap("<Right>", "<C-\\><C-n>:vertical resize -2<CR>", {
  desc = "Resize terminal window to the right (-2)",
})
tnoremap("<Up>", "<C-\\><C-n>:resize +2<CR>", {
  desc = "Resize terminal window to the top (+2)",
})
tnoremap("<Down>", "<C-\\><C-n>:resize -2<CR>", {
  desc = "Resize terminal window to the bottom (-2)",
})
tnoremap("<A-h", "<C-\\><C-n>:bp<CR>", {
  desc = "Go to previous buffer",
})
tnoremap("<A-l", "<C-\\><C-n>:bn<CR>", {
  desc = "Go to next buffer",
})
tnoremap("<Esc><Esc>", "<C-\\><C-n>", {
  desc = "Go to normal mode using double esc",
})

-- Better movement between windows
nnoremap("<C-h>", "<C-w><C-h>", { desc = "Go to the left window" })
nnoremap("<C-l>", "<C-w><C-l>", { desc = "Go to the right window" })
nnoremap("<C-j>", "<C-w><C-j>", { desc = "Go to the bottom window" })
nnoremap("<C-k>", "<C-w><C-k>", { desc = "Go to the top window" })

-- Resize buffer easier
nnoremap("<Left>", ":vertical resize +2<CR>", {
  desc = "Resize buffer to the left",
})
nnoremap("<Right>", ":vertical resize -2<CR>", {
  desc = "Resize buffer to the right",
})
nnoremap("<Up>", ":resize +2<CR>", {
  desc = "Resize buffer to the top",
})
nnoremap("<Down>", ":resize -2<CR>", {
  desc = "Resize buffer to the bottom",
})

-- Buffer movements
noremap("<A-h>", "<CMD>bp<CR>", { desc = "Go to previous buffer" })
noremap("<A-l>", "<CMD>bn<CR>", { desc = "Go to next buffer" })

nnoremap("j", "gj", {
  desc = "Move down by visual line on wrapped lines",
})
nnoremap("k", "gk", {
  desc = "Move up by visual line on wrapped lines",
})

nnoremap("Q", "<Nop>", { desc = "Remove annoying exmode" })
nnoremap("q:", "<Nop>", { desc = "Remove annoying exmode" })

vnoremap("<A-y>", '"+y', {
  desc = "Yank selection to clipboard",
})

nnoremap("<Leader>rl", "<CMD>luafile %<CR>", { desc = "Run Lua file" })
nnoremap("<Leader>rn", "<CMD>!node %<CR>", { desc = "Run file using Node" })
nnoremap("<Leader>rd", "<CMD>!NO_COLOR=true deno run %<CR>", {
  desc = "Run file using Deno",
})

nnoremap("<Leader>n", "<CMD>nohl<CR>", { desc = "Toggle search highlight" })
inoremap("<C-W>", "<C-S-W>", {
  desc = "Delete word backwards (this is needed for telescope prompt)",
})

vnoremap("<", "<gv", { desc = "Dedent current selection" })
vnoremap(">", ">gv", { desc = "Indent current selection" })

nnoremap("<Leader>v", function()
  vim.cmd [[
    vnew
    setlocal buftype=nofile bufhidden=hide
  ]]
end, {
  desc = "Open scratch buffer",
})

nnoremap("<F2>", function()
  vim.cmd [[
    let g:strip_whitespace = !g:strip_whitespace
    echo "Strip whitespace mode is now " . (g:strip_whitespace ? "on" : "off")
  ]]
end, {
  desc = "Toggle whitespace stripping",
})
