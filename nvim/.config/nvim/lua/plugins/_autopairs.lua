vim.cmd [[packadd nvim-autopairs]]
local npairs = require("nvim-autopairs")
local remap = vim.api.nvim_set_keymap

npairs.setup({
  break_line_filetype = nil, -- enable this rule for all filetypes
  pairs_map = {
    ["'"]  = "'",
    ["\""] = "\"",
    ["("]  = ")",
    ["["]  = "]",
    ["{"]  = "}",
    ["`"]  = "`",
  },
  disable_filetype = { "TelescopePrompt" },
  html_break_line_filetype = {
    "html",
    "vue",
    "typescriptreact",
    "svelte",
    "javascriptreact",
  },
  -- ignore alphanumeric, operators, quote, curly brace, and square bracket
  ignored_next_char = "[%w%.%+%-%=%/%,\"'{%[]",
})

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

Util.insert_space = function()
  local is_char_present = Util.check_surroundings()

  if is_char_present then
    return t("  <Left>")
  end

  return t(" ")
end

remap("n", "<Space>", "v:lua.Util.insert_space()", { expr=true,noremap = true })
