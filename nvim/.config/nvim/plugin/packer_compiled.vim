" Automatically generated packer.nvim plugin loader code

if !has('nvim-0.5')
  echohl WarningMsg
  echom "Invalid Neovim version for packer.nvim!"
  echohl None
  finish
endif

packadd packer.nvim

try

lua << END
  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time("Luarocks path setup", true)
local package_path_str = "/home/elianiva/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/elianiva/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/elianiva/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/elianiva/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/elianiva/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time("Luarocks path setup", false)
time("try_loadstring definition", true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    print('Error running ' .. component .. ' for ' .. name)
    error(result)
  end
  return result
end

time("try_loadstring definition", false)
time("Defining packer_plugins", true)
_G.packer_plugins = {
  LuaSnip = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._snippets\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/LuaSnip"
  },
  ["astronauta.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/astronauta.nvim"
  },
  ["better-indent-support-for-php-with-html"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/better-indent-support-for-php-with-html"
  },
  ["curstr.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/curstr.nvim"
  },
  firenvim = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._firenvim\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/firenvim"
  },
  ["formatter.nvim"] = {
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins._formatter\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/formatter.nvim"
  },
  ["git-messenger.vim"] = {
    commands = { "GitMessenger" },
    config = { "\27LJ\2\nC\0\0\2\0\3\0\0056\0\0\0009\0\1\0+\1\2\0=\1\2\0K\0\1\0&git_messenger_no_default_mappings\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/git-messenger.vim"
  },
  ["gitlinker.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14gitlinker\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/gitlinker.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._gitsigns\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["goyo.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/goyo.vim"
  },
  ["hop.nvim"] = {
    commands = { "HopWord" },
    config = { "\27LJ\2\n5\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\bhop\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/hop.nvim"
  },
  ["lsp-trouble.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/lsp-trouble.nvim"
  },
  neogit = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/neogit"
  },
  ["nvim-bufferline.lua"] = {
    config = { "\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24plugins._bufferline\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-bufferline.lua"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\nh\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\6*\1\0\0\1\0\3\tmode\15background\bcss\2\vcss_fn\2\nsetup\14colorizer\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua"
  },
  ["nvim-compe"] = {
    config = { "\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19plugins._compe\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-jdtls"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-jdtls"
  },
  ["nvim-lsp-ts-utils"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig"
  },
  ["nvim-nonicons"] = {
    load_after = {
      ["nvim-web-devicons"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/nvim-nonicons"
  },
  ["nvim-spectre"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-spectre"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._nvimtree\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24plugins._treesitter\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-treesitter-pairs"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-treesitter-pairs"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects"
  },
  ["nvim-ts-context-commentstring"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/nvim-ts-context-commentstring"
  },
  ["nvim-web-devicons"] = {
    after = { "nvim-nonicons" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons"
  },
  ["octo.nvim"] = {
    commands = { "Octo" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/octo.nvim"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["shade.nvim"] = {
    config = { "\27LJ\2\nª\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\tkeys\1\0\3\20brightness_down\r<C-Down>\vtoggle\14<Leader>s\18brightness_up\v<C-Up>\1\0\2\20overlay_opacity\0032\17opacity_step\3\1\nsetup\nshade\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/shade.nvim"
  },
  ["splitjoin.vim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/splitjoin.vim"
  },
  ["sql.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/sql.nvim"
  },
  ["startuptime.vim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/startuptime.vim"
  },
  ["telescope-arecibo.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/telescope-arecibo.nvim"
  },
  ["telescope-frecency.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim"
  },
  ["telescope-media-files.nvim"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/telescope-media-files.nvim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins._telescope\frequire\0" },
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/vim-commentary"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-gruvbox8"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/vim-gruvbox8"
  },
  ["vim-markdown"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/vim-markdown"
  },
  ["vim-sandwich"] = {
    loaded = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/start/vim-sandwich"
  },
  ["vim-sayonara"] = {
    commands = { "Sayonara" },
    loaded = false,
    needs_bufread = false,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/vim-sayonara"
  },
  ["vim-table-mode"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/elianiva/.local/share/nvim/site/pack/packer/opt/vim-table-mode"
  }
}

time("Defining packer_plugins", false)
-- Config for: LuaSnip
time("Config for LuaSnip", true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._snippets\frequire\0", "config", "LuaSnip")
time("Config for LuaSnip", false)
-- Config for: telescope.nvim
time("Config for telescope.nvim", true)
try_loadstring("\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins._telescope\frequire\0", "config", "telescope.nvim")
time("Config for telescope.nvim", false)
-- Config for: nvim-compe
time("Config for nvim-compe", true)
try_loadstring("\27LJ\2\n.\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\19plugins._compe\frequire\0", "config", "nvim-compe")
time("Config for nvim-compe", false)
-- Config for: shade.nvim
time("Config for shade.nvim", true)
try_loadstring("\27LJ\2\nª\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\tkeys\1\0\3\20brightness_down\r<C-Down>\vtoggle\14<Leader>s\18brightness_up\v<C-Up>\1\0\2\20overlay_opacity\0032\17opacity_step\3\1\nsetup\nshade\frequire\0", "config", "shade.nvim")
time("Config for shade.nvim", false)
-- Config for: nvim-tree.lua
time("Config for nvim-tree.lua", true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._nvimtree\frequire\0", "config", "nvim-tree.lua")
time("Config for nvim-tree.lua", false)
-- Config for: nvim-treesitter
time("Config for nvim-treesitter", true)
try_loadstring("\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24plugins._treesitter\frequire\0", "config", "nvim-treesitter")
time("Config for nvim-treesitter", false)
-- Config for: nvim-bufferline.lua
time("Config for nvim-bufferline.lua", true)
try_loadstring("\27LJ\2\n3\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\24plugins._bufferline\frequire\0", "config", "nvim-bufferline.lua")
time("Config for nvim-bufferline.lua", false)
-- Config for: gitlinker.nvim
time("Config for gitlinker.nvim", true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14gitlinker\frequire\0", "config", "gitlinker.nvim")
time("Config for gitlinker.nvim", false)
-- Config for: formatter.nvim
time("Config for formatter.nvim", true)
try_loadstring("\27LJ\2\n2\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\23plugins._formatter\frequire\0", "config", "formatter.nvim")
time("Config for formatter.nvim", false)
-- Config for: firenvim
time("Config for firenvim", true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._firenvim\frequire\0", "config", "firenvim")
time("Config for firenvim", false)
-- Config for: gitsigns.nvim
time("Config for gitsigns.nvim", true)
try_loadstring("\27LJ\2\n1\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\22plugins._gitsigns\frequire\0", "config", "gitsigns.nvim")
time("Config for gitsigns.nvim", false)
-- Config for: lsp-trouble.nvim
time("Config for lsp-trouble.nvim", true)
try_loadstring("\27LJ\2\n9\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ftrouble\frequire\0", "config", "lsp-trouble.nvim")
time("Config for lsp-trouble.nvim", false)

-- Command lazy-loads
time("Defining lazy-load commands", true)
vim.cmd [[command! -nargs=* -range -bang -complete=file HopWord lua require("packer.load")({'hop.nvim'}, { cmd = "HopWord", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file Octo lua require("packer.load")({'octo.nvim'}, { cmd = "Octo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file Sayonara lua require("packer.load")({'vim-sayonara'}, { cmd = "Sayonara", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file GitMessenger lua require("packer.load")({'git-messenger.vim'}, { cmd = "GitMessenger", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
time("Defining lazy-load commands", false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time("Defining lazy-load filetype autocommands", true)
vim.cmd [[au FileType text ++once lua require("packer.load")({'goyo.vim', 'vim-table-mode'}, { ft = "text" }, _G.packer_plugins)]]
vim.cmd [[au FileType html ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "html" }, _G.packer_plugins)]]
vim.cmd [[au FileType css ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "css" }, _G.packer_plugins)]]
vim.cmd [[au FileType typescript ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "typescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascript ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "javascript" }, _G.packer_plugins)]]
vim.cmd [[au FileType svelte ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "svelte" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'goyo.vim', 'vim-table-mode'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType lua ++once lua require("packer.load")({'nvim-colorizer.lua'}, { ft = "lua" }, _G.packer_plugins)]]
time("Defining lazy-load filetype autocommands", false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

END

catch
  echohl ErrorMsg
  echom "Error in packer_compiled: " .. v:exception
  echom "Please check your config for correctness"
  echohl None
endtry
