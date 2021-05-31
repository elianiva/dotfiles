local pears = require("pears")
local R = require("pears.rule")
local on_enter = R.virtual_key(R.VirtualKey.ENTER)

pears.setup(function(conf)
  conf.preset("tag_matching")

  conf.pair("'")
  conf.pair('"')

  conf.pair("{", { close = "}", expand_when = on_enter })
  conf.pair("(", { close = ")", expand_when = on_enter })
  conf.pair("[", { close = "]", expand_when = on_enter })

  conf.on_enter(function(pears_handle)
    if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
      return vim.fn["compe#confirm"]("<CR>")
    else
      pears_handle()
    end
  end)

  conf.expand_on_enter(true)
end)
