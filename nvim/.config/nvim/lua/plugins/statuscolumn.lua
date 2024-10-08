return {
  "luukvbaal/statuscol.nvim",
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
            auto = false
          },
          click = "v:lua.ScSa",
          hl = "SignColumn"
        },
        {
          text = { builtin.lnumfunc },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScLa",
          hl = "SignColumn"
        },
        -- extra spacer
        {
          text = { " ▕" },
          condition = { true, builtin.not_empty },
          hl = "StatusColumnLine"
        },
        {
          text = { " " },
          condition = { true, builtin.not_empty },
        }
      },
    })
  end,
}
