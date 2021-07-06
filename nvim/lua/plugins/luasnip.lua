local ls = require "luasnip"
local s = ls.s -- Snippet
local t = ls.t -- Text
local i = ls.i -- Input
local f = ls.f -- Function

ls.config.set_config {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

local copy = function(args)
  return args[1]
end


local react = {
  ls.parser.parse_snippet(
    { trig = "rfc" },
    [[
export default function $1() {
  return (
    <div>$0</div>
  )
}
    ]]
  ),
}

local dart = {
  ls.parser.parse_snippet(
    { trig = "stl" },
    [[
class ${1:WidgetName} extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    $0
  }
}
    ]]
  ),
  ls.parser.parse_snippet(
    { trig = "stf" },
    [[
class ${1:WidgetName} extends StatefulWidget {
  @override
  _$1 createState() => _$1()
}

class _$1 extends State<$1> {
  @override
  Widget build(BuildContext context) {
    return $0
  }
}
  ]]
  ),
}

ls.snippets = {
  all = {
    ls.parser.parse_snippet({ trig = "todo" }, "TODO(elianiva): ${1:todo}"),
    ls.parser.parse_snippet({ trig = "fixme" }, "FIXME(elianiva): ${1:fixme}"),
    s({ trig = "date" }, {
      t { vim.fn.strftime "%FT%T" },
    }),
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

vim.cmd [[
  imap <silent><expr> <c-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-k>'
  inoremap <silent> <c-j> <cmd>lua require('luasnip').jump(-1)<CR>
  imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
  snoremap <silent> <c-k> <cmd>lua require('luasnip').jump(1)<CR>
  snoremap <silent> <c-j> <cmd>lua require('luasnip').jump(-1)<CR>
]]
