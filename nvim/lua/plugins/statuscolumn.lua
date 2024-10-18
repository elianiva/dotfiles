return {
  "luukvbaal/statuscol.nvim",
  event = "BufEnter",
  dependencies = {
    "lewis6991/gitsigns.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        if
          vim.bo.filetype == "neo-tree" or
          vim.bo.filetype == "dbui"
        then
          vim.wo.statuscolumn = ""
          vim.wo.signcolumn = "no"
          vim.wo.foldcolumn = "0"
        end
      end
    })
  end,
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,
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
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa", hl = "SignColumn" },
        -- extra spacer
        { text = { " ▕" }, hl = "StatusColumnLine" },
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
