vim.cmd[[packadd nvim-autopairs]]
local npairs = require('nvim-autopairs')
local remap = vim.api.nvim_set_keymap

npairs.setup{
  break_line_filetype = {
    'javascript' , 'typescript', 'typescriptreact',
    'svelte', 'go', 'lua', 'java', 'rust', 'json', 'jsonc'
  },
  pairs_map = {
    ["'"] = "'",
    ['"'] = '"',
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['`'] = '`',
  },
  disable_filetype = { "TelescopePrompt" },
  html_break_line_filetype = {
    'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'
  }
}

Util.insert_space = function()
  local is_char_present = Util.check_char("[%{|%}|%[|%]]", true)

  if is_char_present then
    return vim.api.nvim_replace_termcodes("  <Left>", true, false, true)
  end

  return " "
end

remap("i", "<Space>", "v:lua.Util.insert_space()", { expr = true, noremap = true })
