return {
  "supermaven-inc/supermaven-nvim",
  opts = {
    keymaps = {
      accept_suggestion = "<Tab>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    color = {
      suggestion_color = "#5a5a5a",
      cterm = 244,
    },
    ignore_filetypes = {
      dbui = true,
      dbout = true,
      DressingInput = true,
      ["neo-tree-popup"] = true,
    }
  },
}
