local k = require("astronauta.keymap")

local noremap = k.noremap
local nnoremap = k.nnoremap
local inoremap = k.inoremap
local vnoremap = k.vnoremap
local nmap = k.nmap
local xmap = k.xmap

-- use jj instead of Esc
-- 4 mappings to prevent typos :p
inoremap { "jj", "<Esc><Esc>" }
inoremap { "Jj", "<Esc><Esc>" }
inoremap { "jJ", "<Esc><Esc>" }
inoremap { "JJ", "<Esc><Esc>" }

-- toggle nvimtree
nnoremap { "<C-n>", "<CMD>NvimTreeToggle<CR>" }

-- hippity hoppity your word is not my property
nnoremap { "<Leader>w", "<CMD>HopWord<CR>" }

-- toggle telescope.nvim
nnoremap {
  "<C-p>",
  require("plugins._telescope").files,
  { silent = true },
}
nnoremap {
  "<C-f>",
  require("plugins._telescope").grep_prompt,
  { silent = true },
}
nnoremap {
  "<Leader>fb",
  require("plugins._telescope").buffer_fuzzy,
  { silent = true },
}
nnoremap {
  "<Leader>ff",
  require("plugins._telescope").frecency,
  { silent = true },
}
nnoremap {
  "<Leader>fm",
  require("telescope").extensions.media_files.media_files,
  { silent = true },
}
nnoremap {
  "<Leader>fa",
  require("plugins._telescope").arecibo,
  { silent = true },
}
nnoremap {
  "<Leader>fl",
  require("plugins._telescope").file_browser,
  { silent = true },
}

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
vnoremap { "<A-y>", "\"+y" }

-- no distraction mode for writing
-- nnoremap { "<Leader>gg", "<CMD>Goyo<CR>" }

-- run luafile on current file
-- rl stands for `run lua`
nnoremap { "<Leader>rl", "<CMD>luafile %<CR>" }

-- run node on current file
-- rn stands for `run node`
-- rd stands for `run deno`
nnoremap { "<Leader>rn", "<CMD>!node %<CR>" }
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

vim.cmd [[
  command! -nargs=0 Center :lua require("modules._center").centered()
]]

-- better indenting experience
vnoremap { "<", "<gv" }
vnoremap { ">", ">gv" }

xmap { "ga", "<Plug>(EasyAlign)", { silent = true }}

nmap {"<Leader>t", "<Plug>PlenaryTestFile", { silent = true }}

nmap {
  "<F2>",
  ":let g:strip_whitespace = !g:strip_whitespace | echo 'Strip whitespace mode toggled!'<CR>",
  { silent = true },
}

local curstr = require("curstr").execute

nnoremap {
  "gf",
  function()
    if vim.bo.filetype == "lua" then
      return curstr("vim/lua")
    end

    return curstr("file/path")
  end,
  { silent = true }
}
