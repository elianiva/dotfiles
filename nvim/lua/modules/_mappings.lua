local k = vim.keymap
local noremap = k.noremap
local nnoremap = k.nnoremap
-- local inoremap = k.inoremap
local vnoremap = k.vnoremap
local nmap = k.nmap
local xmap = k.xmap

-- toggle nvimtree
nnoremap { "<C-n>", "<CMD>NvimTreeToggle<CR>" }

-- hippity hoppity your word is not my property
nnoremap { "<Leader>w", "<CMD>HopWord<CR>" }

-- better movement between windows
nnoremap { "<C-h>", "<C-w><C-h>" }
nnoremap { "<C-j>", "<C-w><C-j>" }
nnoremap { "<C-k>", "<C-w><C-k>" }
nnoremap { "<C-l>", "<C-w><C-l>" }

-- resize buffer easier
nnoremap { "<Left>", "<CMD>vertical resize +2<CR>" }
nnoremap { "<Right>", "<CMD>vertical resize -2<CR>" }
nnoremap { "<Up>", "<CMD>resize +2<CR>" }
nnoremap { "<Down>", "<CMD>resize -2<CR>" }

-- buffer movements
noremap { "<A-j>", "<CMD>Sayonara!<CR>" }
noremap { "<A-k>", "<CMD>Sayonara<CR>" }
noremap { "<A-h>", "<CMD>bp<CR>" }
noremap { "<A-l>", "<CMD>bn<CR>" }

-- move vertically by visual line on wrapped lines
nnoremap { "j", "gj" }
nnoremap { "k", "gk" }

-- move vertically by visual line on wrapped lines
nnoremap { "j", "gj" }
nnoremap { "k", "gk" }

-- better yank behaviour
nnoremap { "Y", "y$" }

-- remove annoying exmode
nnoremap { "Q", "<Nop>" }
nnoremap { "q:", "<Nop>" }

-- copy to system clipboard
vnoremap { "<A-y>", '"+y' }

-- rl stands for `run lua`
nnoremap { "<Leader>rl", "<CMD>luafile %<CR>" }
-- rn stands for `run node`
nnoremap { "<Leader>rn", "<CMD>!node %<CR>" }
-- rd stands for `run deno`
nnoremap { "<Leader>rd", "<CMD>!NO_COLOR=true deno run %<CR>" }

-- toggle hlsearch
nnoremap { "<Leader>n", "<CMD>nohl<CR>" }

-- toggle colorizer
nnoremap { "<Leader>c", "<CMD>ColorizerToggle<CR>" }

-- open vertical scratch buffer
nnoremap {
  "<Leader>v",
  "<CMD>vnew | setlocal buftype=nofile | setlocal bufhidden=hide<CR>",
}

-- better indenting experience
vnoremap { "<", "<gv" }
vnoremap { ">", ">gv" }

xmap { "ga", "<Plug>(EasyAlign)", { silent = true } }

nmap {
  "<F2>",
  ":let g:strip_whitespace = !g:strip_whitespace | echo 'Strip whitespace mode toggled!'<CR>",
  { silent = true },
}
