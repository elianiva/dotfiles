local pears = require("pears")
local R = require("pears.rule")
local on_enter = R.virtual_key(R.VirtualKey.ENTER)

pears.setup(function(conf)
  conf.preset("tag_matching", {
    filetypes = {
      "html",
      "php",
      "svelte",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    }
  })

  conf.pair("'")
  conf.pair('"')

  conf.pair("{", { close = "}", expand_when = on_enter })
  conf.pair("(", { close = ")", expand_when = on_enter })
  conf.pair("[", { close = "]", expand_when = on_enter })

  conf.on_enter(function(pears_handle)
    if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
      return vim.fn["compe#confirm"]("<CR>")
    end

    local line, col = vim.fn.getline("."), vim.fn.col(".")
    local prev_col, next_col = col - 1, col
    local prev_char = line:sub(prev_col, prev_col)
    local next_char = line:sub(next_col, next_col)

    if prev_char == ">" and next_char == "<" then
      return Util.t("<CR><C-o>O")
    end

    pears_handle()
  end)

  conf.expand_on_enter(true)
end)
