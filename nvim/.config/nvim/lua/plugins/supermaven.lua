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
    condition = function()
      return vim.bo.filetype == "dbui" or vim.bo.filetype == "dbout"
    end
  },
}
