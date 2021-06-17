local wk = require("which-key")

wk.register({
  f = {
    name = "+Telescope",
    f    = "Frecency" ,
    b    = "Buffer Fuzzy" ,
    l    = "File Browser" ,
  },
  g = {
    name  = "+LSP",
    a     = "Code Action" ,
    d     = "Symbol Definition(s)" ,
    r     = "Symbol Reference(s)" ,
    R     = "Rename Symbol" ,
    D     = "Show Line Diagnostic" ,
    ["]"] = "Next Diagnostic",
    ["["] = "Prev Diagnostic" ,
  },
  d = {
    name  = "+DAP",
    b     = "Toggle Breakpoint" ,
    c     = "Continue" ,
    o     = "Step Over" ,
    r     = "Open REPL" ,
    ['>'] = "Step Into" ,
    ['<'] = "Step Out" ,
  },
  h = {
    name  = "+GitSigns",
    b     = "Blame Line" ,
    R     = "Reset Buffer" ,
    p     = "Preview Hunk" ,
    r     = "Reset Hunk" ,
    s     = "Stage Hunk",
    u     = "Undo Hunk" ,
  },
  r = {
    name  = "+Execute",
    n     = "Node" ,
    l     = "Lua" ,
    d     = "Deno" ,
    r     = "Rest Client" ,
  },
  i = "Start Incremental Selection",
  v = "Open Scratch Split",
  t = "Run Plenary Test",
  n = "Disable Matching Highlight",
  a = "Swap With Next Parameter",
  A = "Swap With Prev Parameter",
  w = "Hop To Arbitrary Word",
}, { prefix = "<leader>" })

wk.register({
  gc = "Comments",
  gJ = "Join Multiline",
  gS = "Split Into Multiline",

  -- vim-sandwich
  sa = "Add Surrounding Character",
  sd = "Remove Surrounding Character",
  sr = "Replace Surrounding Character",
})

wk.setup {
  plugins = {
    marks = true,
    registers = true,
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
    -- border = { "", "▔", "", "", "", "", "", "" }, -- none, single, double, shadow
    border = "none",
    position = "bottom", -- bottom, top
    margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 4, 2, 4, 2 }, -- extra window padding [top, right, bottom, left]
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 8, -- spacing between columns
  },
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  hidden = {
    "<silent>",
    "<cmd>",
    "<Cmd>",
    "<CR>",
    "call",
    "lua",
    "^:",
    "^ ",
  }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  triggers = "auto", -- automatically setup triggers
}
