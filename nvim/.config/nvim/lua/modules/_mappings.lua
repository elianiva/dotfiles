local k = require"astronauta.keymap"

local noremap =  k.noremap
local nnoremap = k.nnoremap
local inoremap = k.inoremap
local vnoremap = k.vnoremap

-- use jj instead of Esc
-- 4 mappings to prevent typos :p
inoremap{"jj", "<Esc><Esc>"}
inoremap{"Jj", "<Esc><Esc>"}
inoremap{"jJ", "<Esc><Esc>"}
inoremap{"JJ", "<Esc><Esc>"}

-- toggle nvimtree
nnoremap{"<C-n>", "<CMD>NvimTreeToggle<CR>"}

-- hippity hoppity your word is not my property
nnoremap{"<Leader>w", "<CMD>HopWord<CR>"}

-- toggle telescope.nvim
nnoremap{"<C-p>", require"plugins._telescope".files, { silent = true }}
nnoremap{"<C-f>", require"plugins._telescope".grep_prompt, { silent = true }}
nnoremap{
  "<Leader>tb",
  function()
    return require"telescope.builtin".current_buffer_fuzzy_find(
      require('telescope.themes').get_dropdown({})
    )
  end,
  { silent = true },
}
nnoremap{
  "<Leader>tf",
  function()
    return require"telescope".extensions.frecency.frecency(
      require('telescope.themes').get_dropdown({previewer = false})
    )
  end,
  { silent = true },
}
nnoremap{
  "<Leader>tm",require"telescope".extensions.media_files.media_files,
  { silent = true },
}

-- better movement between windows
nnoremap{"<C-h>", "<C-w><C-h>"}
nnoremap{"<C-j>", "<C-w><C-j>"}
nnoremap{"<C-k>", "<C-w><C-k>"}
nnoremap{"<C-l>", "<C-w><C-l>"}

-- resize buffer easier
nnoremap{"<Left>", "<CMD>vertical resize +2<CR>"}
nnoremap{"<Right>", "<CMD>vertical resize -2<CR>"}
nnoremap{"<Up>", "<CMD>resize +2<CR>"}
nnoremap{"<Down>", "<CMD>resize -2<CR>"}

-- buffer movements
noremap{"<A-j>", "<CMD>Sayonara!<CR>"}
noremap{"<A-k>", "<CMD>Sayonara<CR>"}
noremap{"<A-h>", "<CMD>bp<CR>"}
noremap{"<A-l>", "<CMD>bn<CR>"}

-- move vertically by visual line on wrapped lines
nnoremap{"j", "gj"}
nnoremap{"k", "gk"}

-- move vertically by visual line on wrapped lines
nnoremap{"j", "gj"}
nnoremap{"k", "gk"}

-- better yank behaviour
nnoremap{"Y", "y$"}

-- remove annoying exmode
nnoremap{"Q", "<Nop>"}
nnoremap{"q:", "<Nop>"}

-- copy to system clipboard
vnoremap{"<A-y>", '"+y'}

-- no distraction mode for writing
nnoremap{"<Leader>gg", "<CMD>Goyo<CR>"}

-- run luafile on current file
nnoremap{"<Leader>r", "<CMD>luafile %<CR>"}

-- run node on current file
nnoremap{"<Leader>n", "<CMD>!node %<CR>"}
nnoremap{"<Leader>tn", "<CMD>!NO_COLOR=true deno run %<CR>"}

-- toggle colorizer
nnoremap{"<Leader>c", "<CMD>ColorizerToggle<CR>"}

-- open vertical scratch buffer
nnoremap{"<Leader>v", "<CMD>vnew | setlocal buftype=nofile | setlocal bufhidden=hide<CR>"}

-- cd to currently opened file
nnoremap{"<Leader>d", "<CMD>cd %:p:h<CR>"}

-- better indenting experience
vnoremap{"<", "<gv"}
vnoremap{">", ">gv"}

nnoremap{"gx", Util.xdg_open, { silent = true }}
