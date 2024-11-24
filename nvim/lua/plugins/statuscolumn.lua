return {
  "luukvbaal/statuscol.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  event = "BufEnter",
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        local ft = vim.bo.filetype
        if ft == "dbui" or ft == "neo-tree" or ft == "snacks_notif" then
          vim.o.signcolumn = "no"
          vim.o.foldcolumn = "0"
        end
      end,
    })
  end,
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      setopt = true,
      relculright = true,
      ft_ignore = { "dbui", "neo-tree" },
      bt_ignore = { "nofile" },
      segments = {
        {

          text = { builtin.foldfunc },
          click = "v:lua.ScFa",
          hl = "SignColumn"
        },
        {
          sign = {
            namespace = { "diagnostic/signs" },
            maxwidth = 1,
            auto = false,
            fillcharhl = "SignColumn"
          },
          click = "v:lua.ScSa",
          hl = "SignColumn"
        },
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
        -- extra spacer
        -- { text = { " ▕" } },
        { text = { "  " } },
        {
          sign = {
            namespace = { "gitsigns" },
            name = { ".*" },
            maxwidth = 1,
            auto = false,
            fillcharhl = "Normal"
          },
          click = "v:lua.ScSa",
        },
      },
    })
  end,
}
