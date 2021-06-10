local ls = require("luasnip")
local s = ls.s -- Snippet
local t = ls.t -- Text
local i = ls.i -- Input
local f = ls.f -- Function
local k = require("astronauta.keymap")
local inoremap = k.inoremap
local snoremap = k.snoremap

local react = {
  s({ trig = "rfc" }, {
    t({ "export default function " }) , i(1),
    t({
      "() {",
      "\treturn (",
      "\t\t<div>"
    }),
    i(0),
    t({
      "</div>",
      "\t)",
      "}",
    }),
  }),
}

local copy = function(args) return args[1] end

local LOREM_IPSUM  = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

ls.snippets = {
  all = {
    ls.parser.parse_snippet({ trig = "todo" }, "TODO(elianiva): ${1:todo}"),
    ls.parser.parse_snippet({ trig = "fixme" }, "FIXME(elianiva): ${1:fixme}"),
    s({trig = "lorem(%d+)", regTrig = true, wordTrig = true}, {
      f(function(args)
        local amount = tonumber(args[1].captures[1])
        local words = vim.split(LOREM_IPSUM, " ")
        if amount == nil then return { LOREM_IPSUM } end

        local result = table.concat(vim.list_slice(words, 1, amount + 1), " ")
        return { result }
      end, {}),
      i(0),
    }),
  },
  php = {
    ls.parser.parse_snippet({ trig = "php" }, "<?php $0 ?>"),
    ls.parser.parse_snippet({ trig = "phpp" }, "<?= $0 ?>"),
  },
  javascriptreact = react,
  typescriptreact = react,
  tex = {
    ls.parser.parse_snippet({ trig = "us" }, "\\usepackage{$0}"),
    ls.parser.parse_snippet({ trig = "bf" }, "\\textbf{$0}"),
    ls.parser.parse_snippet({ trig = "it" }, "\\textit{$0}"),
    ls.parser.parse_snippet({ trig = "tt" }, "\\texttt{$0}"),
    s({ trig = "beg" }, {
      t({"\\begin{"}),
      i(1),
      t({"}", ""}),
      i(0),
      t({ "", "\\end{" }),
      f(copy, {1}),
      t({"}"}),
    }),
  }
}


inoremap {
  "<C-j>",
  function()
    print(ls.expand_or_jumpable())
    if ls.expand_or_jumpable() then
      return ls.expand_or_jump()
    end
    Util.t("<C-j>")
  end,
  { silent = true }
}

inoremap {
  "<C-k>",
  function()
    return ls.jumpable(-1) and ls.jump_prev() or Util.t("<C-j>")
  end,
  { silent = true },
}

snoremap { "<C-j>", function() return ls.jump(1) end, { silent = true }}

snoremap { "<C-k>", function() return ls.jump(-1) end, { silent = true }}
