Util = {}

Util.check_backspace = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

Util.check_html_char = function()
  local prev_col = vim.fn.col('.') - 1
  local next_col = vim.fn.col('.')
  local prev_char = vim.fn.getline('.'):sub(prev_col, prev_col)
  local next_char = vim.fn.getline('.'):sub(next_col, next_col)

  if prev_char:match('>') and next_char:match('<') then
    return true
  else
    return false
  end
end

-- preview file using xdg_open
Util.xdg_open = function()
  local filename = vim.fn.expand("<cfile>")
  vim.loop.spawn("xdg-open", {args = {filename}})
end

local to_rgb = function(hex)
  local _, red, green, blue = hex:match('(.)(..)(..)(..)')

  return string.format(
    'rgb(%s, %s, %s)',
    tonumber("0x" .. red), tonumber("0x" .. green), tonumber("0x" .. blue)
  )
end

local to_hex = function(rgb)
  local red, green, blue = rgb:match("%((%d+),%s(%d+),%s(%d+)")
  return string.format('#%x%x%x', red, green, blue)
end

local get_word = function()
  local first_line_num, last_line_num = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
  local first_col, last_col = vim.fn.getpos("'<")[3], vim.fn.getpos("'>")[3]
  local current_word = vim.fn.getline(first_line_num, last_line_num)[1]:sub(first_col, last_col)

  return current_word
end

Util.convert_color = function(mode)
  local result

  if mode == 'rgb' then
    result = to_rgb(get_word())
  else
    result = to_hex(get_word())
  end

  vim.api.nvim_command(string.format('s/%s/%s', get_word(), result))
end

vim.api.nvim_exec([[
  command! -nargs=? -range=% ToRgb call v:lua.Util.convert_color('rgb')
  command! -nargs=? -range=% ToHex call v:lua.Util.convert_color('hex')
]], true)
