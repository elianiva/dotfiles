local get_mapper = function(mode, noremap)
  return function(lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = noremap
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

local noremap = get_mapper("n", false)
local nnoremap = get_mapper("n", true)
local inoremap = get_mapper("i", true)
local tnoremap = get_mapper("t", true)
local vnoremap = get_mapper("v", true)
local xnoremap = get_mapper("x", true)
local cnoremap = get_mapper("c", true)

-- stolen from justinmk
nnoremap("/", "ms/", { desc = "Keeps jumplist after forward searching" })
nnoremap("?", "ms?", { desc = "Keeps jumplist after backward searching" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
noremap("n", '"Nn"[v:searchforward]', {
  expr = true,
  desc = "Better forward N behaviour",
})
noremap("N", '"nN"[v:searchforward]', {
  expr = true,
  desc = "Better backward N behaviour",
})

nnoremap("<C-n>", "<CMD>Neotree toggle<CR>", { desc = "Toggle NeoTree" })

-- Better movement between windows
nnoremap("<C-h>", "<C-w><C-h>", { desc = "Go to the left window" })
nnoremap("<C-l>", "<C-w><C-l>", { desc = "Go to the right window" })
nnoremap("<C-j>", "<C-w><C-j>", { desc = "Go to the bottom window" })
nnoremap("<C-k>", "<C-w><C-k>", { desc = "Go to the top window" })

-- better behaviour on wrapped lines
nnoremap("j", "gj", { desc = "Move down by visual line on wrapped lines" })
nnoremap("k", "gk", { desc = "Move up by visual line on wrapped lines" })

-- remove annoying exmode
nnoremap("Q", "<Nop>", { desc = "Remove annoying exmode" })
nnoremap("q:", "<Nop>", { desc = "Remove annoying exmode" })

vnoremap("<A-y>", '"+y', { desc = "Yank selection to clipboard" })
vnoremap("<", "<gv", { desc = "Dedent current selection" })
vnoremap(">", ">gv", { desc = "Indent current selection" })

nnoremap("<Leader>n", "<CMD>nohl<CR>", { desc = "Toggle search highlight" })
inoremap("<C-W>", "<C-S-W>", { desc = "Delete word backwards" })

-- Terminal escape
tnoremap("<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

nnoremap("<Leader>d", '"_d', { desc = "Delete to black hole" })
xnoremap("<Leader>d", '"_d', { desc = "Delete to black hole" })
nnoremap("x", '"_x', { desc = "Delete char (no yank)" })
xnoremap("x", '"_x', { desc = "Delete char (no yank)" })

-- Smart paste: don't yank replaced text in visual mode
xnoremap("p", '"_dP', { desc = "Paste without yanking replaced text" })

-- Resize splits with Alt+arrow
nnoremap("<A-Up>", "<CMD>resize +2<CR>", { desc = "Increase height" })
nnoremap("<A-Down>", "<CMD>resize -2<CR>", { desc = "Decrease height" })
nnoremap("<A-Left>", "<CMD>vertical resize -2<CR>", { desc = "Decrease width" })
nnoremap("<A-Right>", "<CMD>vertical resize +2<CR>", { desc = "Increase width" })
nnoremap("<Leader>=", "<C-w>=", { desc = "Equalize splits" })

-- Better search: clear with Esc, search in visual selection
xnoremap("/", "<C-\\><C-n>/\\%V", { desc = "Search in visual selection" })
xnoremap("*", '"zy/<C-r>z<CR>', { desc = "Search visual selection forward" })
xnoremap("#", '"zy?<C-r>z<CR>', { desc = "Search visual selection backward" })

-- Buffer navigation
nnoremap("]b", "<CMD>bnext<CR>", { desc = "Next buffer" })
nnoremap("[b", "<CMD>bprev<CR>", { desc = "Previous buffer" })
nnoremap("<Leader>bb", "<CMD>b#<CR>", { desc = "Last buffer (alternate)" })
nnoremap("<Leader>bw", "<CMD>bw<CR>", { desc = "Wipe buffer" })

-- Smart home: 0 goes to first non-blank, again to column 0
local function smart_home()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local first_nonblank = line:find("([^%s])") or 1
  if col == first_nonblank - 1 then
    return "0"
  else
    return "^"
  end
end
nnoremap("0", smart_home, { expr = true, desc = "Smart home" })
nnoremap("^", "0", { desc = "Go to column 0" })

-- Command line editing (Emacs-style)
cnoremap("<C-a>", "<Home>", { desc = "Start of line" })
cnoremap("<C-e>", "<End>", { desc = "End of line" })
cnoremap("<C-f>", "<Right>", { desc = "Forward char" })
cnoremap("<C-b>", "<Left>", { desc = "Backward char" })
cnoremap("<C-d>", "<Del>", { desc = "Delete char" })
cnoremap("<C-k>", '<C-\\>e strpart(getcmdline(), 0, getcmdpos()-1)<CR>', { desc = "Delete to end" })

-- Quickfix and location list navigation
nnoremap("<Leader>qf", "<CMD>copen<CR>", { desc = "Open quickfix" })
nnoremap("<Leader>ql", "<CMD>lopen<CR>", { desc = "Open location list" })
nnoremap("]q", "<CMD>cnext<CR>zz", { desc = "Next quickfix" })
nnoremap("[q", "<CMD>cprev<CR>zz", { desc = "Prev quickfix" })
nnoremap("]l", "<CMD>lnext<CR>zz", { desc = "Next location" })
nnoremap("[l", "<CMD>lprev<CR>zz", { desc = "Prev location" })
nnoremap("<Leader>qn", "<CMD>cn<CR>", { desc = "Next quickfix" })
nnoremap("<Leader>qp", "<CMD>cp<CR>", { desc = "Prev quickfix" })

-- Copy file paths
nnoremap("<Leader>yf", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Yank relative file path" })
nnoremap("<Leader>yF", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Yank absolute file path" })

-- Undo breakpoints on punctuation (better undo granularity)
inoremap(",", ",<C-g>u")
inoremap(".", ".<C-g>u")
inoremap(";", ";<C-g>u")
inoremap("!", "!<C-g>u")
inoremap("?", "?<C-g>u")

-- Repeat last action in visual mode
xnoremap(".", "<CMD>norm.<CR>", { desc = "Repeat last action" })
