local wk = require "which-key"

wk.register({
  t = {
    name = "+Test",
    n = "TestNearest",
    f = "TestFile",
    s = "TestSuite",
    l = "TestLast",
    g = "TestVisit",
  },
  f = {
    name = "+Telescope",
    f = "Telescope frecency",
    b = "Telescope current_buffer_fuzzy_find",
    g = "Telescope git_commits",
    t = "Telescope builtins",
    l = {
      name = "+LSP",
      s = "Workspace Symbols",
    },
    n = {
      name = "+NPM",
      s = "Scripts",
      p = "Packages",
    },
  },
  g = {
    name = "+LSP",
    f = "Format Document",
    a = "Code Action",
    d = "Symbol Definition(s)",
    r = "Symbol Reference(s)",
    R = "Rename Symbol",
    D = "Show Line Diagnostic",
    l = "Run Codelense",
    ["]"] = "Next Diagnostic",
    ["["] = "Prev Diagnostic",
  },
  h = {
    name = "+GitSigns",
    b = "Blame Line",
    R = "Reset Buffer",
    P = "Preview Hunk",
    r = "Reset Hunk",
    s = "Stage Hunk",
    u = "Undo Hunk",
    n = "Next Hunk",
    p = "Prev Hunk",
  },
  r = {
    name = "+Execute",
    n = "Node",
    l = "Lua",
    d = "Deno",
  },
  v = "Open Scratch Split",
  n = "Disable Matching Highlight",
  a = "Swap With Next Parameter",
  A = "Swap With Prev Parameter",
  w = "Hop To Arbitrary Word",
}, {
  prefix = "<leader>",
})

wk.register {
  gc = "Comments",
  gJ = "Join Multiline",
  gS = "Split Into Multiline",

  -- vim-sandwich
  sa = "Add Surrounding Character",
  sd = "Remove Surrounding Character",
  sr = "Replace Surrounding Character",
}

wk.setup {
  plugins = {
    marks = false,
    registers = false,
    spelling = { enabled = false },
    presets = {
      operators = false,
      motions = false,
      text_objects = false,
      windows = true,
      z = true,
      g = true,
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  operators = { gc = "Comments" },
  icons = {
    breadcrumb = "»",
    separator = "➜ ",
    group = "+",
  },
  window = {
    border = "none",
    position = "bottom",
    margin = { 0, 0, 0, 0 }, -- TRBL
    padding = { 4, 2, 4, 2 }, -- TRBL
  },
  layout = {
    height = {
      min = 4,
      max = 25,
    },
    width = {
      min = 20,
      max = 50,
    },
    spacing = 8,
  },
  ignore_missing = false,
  hidden = {
    "<silent>",
    "<cmd>",
    "<Cmd>",
    "<CR>",
    "call",
    "lua",
    "^:",
    "^ ",
  },
  show_help = true,
  triggers = "auto",
  triggers_blacklist = {
    i = { "," },
    n = { "'" },
  },
}
