-- vim.cmd [[packadd vim-vsnip]]
vim.cmd([[packadd LuaSnip]])
local ls = require("luasnip")
local k = require("astronauta.keymap")
local inoremap = k.inoremap
local snoremap = k.snoremap

ls.snippets = {
  all = {
    ls.parser.parse_snippet({ trig = "todo" }, "TODO(elianiva): ${1:todo}"),
    ls.parser.parse_snippet({ trig = "fixme" }, "FIXME(elianiva): ${1:fixme}"),
  },
}


inoremap {
  "<C-j>",
  function()
    return ls.expand_or_jumpable() and ls.expand_or_jump() or Util.t("<C-j>")
  end,
  { silent = true }
}

snoremap {
  "<C-j>",
  function()
    return ls.expand_or_jumpable() and ls.expand_or_jump() or Util.t("<C-j>")
  end,
  { silent = true }
}

inoremap {
  "<C-k>",
  function() require("luasnip").jump(-1) end,
  { silent = true },
}

snoremap {
  "<C-k>",
  function() require("luasnip").jump(-1) end,
  { silent = true },
}
