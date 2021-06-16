local ls = require "luasnip"
local s = ls.s -- Snippet
local t = ls.t -- Text
local i = ls.i -- Input
local f = ls.f -- Function
-- local d = ls.d -- Dynamic
-- local c = ls.c -- Choice
-- local sn = ls.sn -- Snip
local k = require "modules._keymap"
local inoremap = k.inoremap
local snoremap = k.snoremap

local copy = function(args)
  return args[1]
end

-- -- 'recursive' dynamic snippet. Expands to some text followed by itself.
-- local rec_ls
-- rec_ls = function()
--   return sn(nil, {
--     c(1, {
--       -- Order is important, sn(...) first would cause infinite loop of expansion.
--       t({""}),
--       sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}),
--     }),
--   });
-- end

local react = {
  ls.parser.parse_snippet({ trig = "rfc" },[[
export default function $1() {
  return (
    <div>$0</div>
  )
}
  ]]),
}

local dart = {
  ls.parser.parse_snippet({ trig = "stl" }, [[
class ${1:WidgetName} extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    $0
  }
}
  ]]),
  ls.parser.parse_snippet({ trig = "stf" }, [[
class ${1:WidgetName} extends StatefulWidget {
  @override
  _$1 createState() => _$1
}

class _$1 extends State<$1> {
  @override
  Widget build(BuildContext context) {
    $0
  }
}
  ]]),
}

ls.snippets = {
  all = {
    ls.parser.parse_snippet({ trig = "todo" }, "TODO(elianiva): ${1:todo}"),
    ls.parser.parse_snippet({ trig = "fixme" }, "FIXME(elianiva): ${1:fixme}"),
  },
  php = {
    ls.parser.parse_snippet({ trig = "php" }, "<?php $0 ?>"),
    ls.parser.parse_snippet({ trig = "phpp" }, "<?= $0 ?>"),
  },
  dart = dart,
  javascriptreact = react,
  typescriptreact = react,
  tex = {
    ls.parser.parse_snippet({ trig = "us" }, "\\usepackage{$0}"),
    ls.parser.parse_snippet({ trig = "bf" }, "\\textbf{$0}"),
    ls.parser.parse_snippet({ trig = "it" }, "\\textit{$0}"),
    ls.parser.parse_snippet({ trig = "tt" }, "\\texttt{$0}"),
    s({ trig = "beg" }, {
      t { "\\begin{" },
      i(1),
      t { "}", "" },
      i(0),
      t { "", "\\end{" },
      f(copy, { 1 }),
      t { "}" },
    }),
  },
}

snoremap { "<C-j>", function()
  return ls.jump(1)
end, { silent = true } }
inoremap {
  "<C-j>",
  function()
    return ls.expand_or_jumpable() and ls.expand_or_jump() or Util.t "<C-j>"
  end,
  { silent = true },
}

snoremap { "<C-k>", function()
  return ls.jump(-1)
end, { silent = true } }
inoremap {
  "<C-k>",
  function()
    return ls.jumpable(-1) and ls.jump_prev() or Util.t "<C-j>"
  end,
  { silent = true },
}

-- snoremap {
--   "<C-e>",
--   function()
--     return ls.choice_active() and ls.change_choice(1) or Util.t("<C-e>")
--   end,
--   { silent = true },
-- }
-- inoremap {
--   "<C-e>",
--   function()
--     P(ls.choice_active())
--     return ls.choice_active() and ls.change_choice(1) or Util.t("<C-e>")
--   end,
--   { silent = true },
-- }
