local Job = require("plenary.job")
local fn = vim.fn

_G.Util = {}

P = function(stuff) return print(vim.inspect(stuff)) end

Util.check_backspace = function()
  local curr_col = fn.col('.')
  local is_first_col = fn.col('.') - 1 == 0
  local prev_char = fn.getline('.'):sub(curr_col - 1, curr_col - 1)

  if is_first_col or prev_char:match("%s") then
    return true
  else
    return false
  end
end

Util.check_surroundings = function()
  local col = fn.col('.')
  local line = fn.getline('.')
  local prev_char = line:sub(col - 1, col - 1)
  local next_char = line:sub(col, col)
  local pattern = '[%{|%}|%[|%]]'

  if prev_char:match(pattern) and next_char:match(pattern) then
    return true
  else
    return false
  end
end

-- preview file using xdg_open
Util.xdg_open = function()
  local filename = fn.expand("<cfile>")
  vim.loop.spawn("xdg-open", {args = {filename}})
end

local to_rgb = function(hex)
  local red, green, blue, alpha

  if #hex == 9 then
    _, red, green, blue, alpha = hex:match('(.)(..)(..)(..)(..)')
    return string.format(
      'rgba(%s, %s, %s, %s)',
      tonumber("0x" .. red), tonumber("0x" .. green),
      tonumber("0x" .. blue), tonumber("0x" .. alpha)
    )
  end

  _, red, green, blue = hex:match('(.)(..)(..)(..)')
  return string.format(
    'rgb(%s, %s, %s)',
    tonumber("0x" .. red), tonumber("0x" .. green), tonumber("0x" .. blue)
  )
end

local to_hex = function(rgb)
  local red, green, blue, alpha
  if #rgb >= 16 then
    red, green, blue, alpha = rgb:match("%((%d+),%s(%d+),%s(%d+),%s(%d+)")
    return string.format('#%x%x%x%x', red, green, blue, alpha)
  end

  red, green, blue = rgb:match("%((%d+),%s(%d+),%s(%d+)")
  return string.format('#%x%x%x', red, green, blue)
end

Util.get_word = function()
  local first_line, last_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local first_col, last_col = fn.getpos("'<")[3], fn.getpos("'>")[3]
  local current_word = fn.getline(first_line, last_line)[1]:sub(first_col, last_col)

  return current_word
end

-- don't actually use this but I thought this might come in handy who knows ;)
Util.get_lines = function()
  local first_line, last_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local lines = fn.getline(first_line, last_line)

  return lines
end

-- don't actually use this but I thought this might come in handy who knows ;)
Util.get_visual = function()
  local first_line, last_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local first_col, last_col = fn.getpos("'<")[3], fn.getpos("'>")[3]
  local lines = fn.getline(first_line, last_line)

  if #lines == 0 then return "" end

  lines[#lines] = lines[#lines]:sub(0, last_col - 2)
  lines[1] = lines[1]:sub(first_col - 1, -1)

  return lines
end

-- just for fun :p
Util.strike_through = function()
  local first_line, _ = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local first_col, last_col = fn.getpos("'<")[3], fn.getpos("'>")[3]

  local strike_ns = vim.api.nvim_create_namespace("striked_text")

  vim.api.nvim_buf_add_highlight(
    0, strike_ns, "StrikeThrough", first_line - 1, first_col - 1, last_col
  )
end

Util.convert_color = function(mode)
  local result

  if mode == 'rgb' then
    result = to_rgb(Util.get_word())
  elseif mode == 'hex' then
    result = to_hex(Util.get_word())
  else
    return print("Not Supported!")
  end

  vim.api.nvim_command(string.format('s/%s/%s', Util.get_word(), result))
end

vim.api.nvim_exec([[
  command! -nargs=? -range=% ToRgb call v:lua.Util.convert_color('rgb')
  command! -nargs=? -range=% ToHex call v:lua.Util.convert_color('hex')
]], false)

-- translate selected word, useful for when I do jp assignments
Util.translate = function(lang)
  local word = Util.get_word()
  local job = Job:new({
    command = "trans",
    args = {"-b", ":" .. (lang or "en"), word}
  })

  local ok, result = pcall(function() return vim.trim(job:sync()[1]) end)
  if ok then print(result) end
end
vim.cmd('command! -range -nargs=1 Translate call v:lua.Util.translate(<f-args>)')

Util.is_cfg_present = function(cfg_name)
  -- this returns 1 if it's not present and 0 if it's present
  -- we need to compare it with 1 because both 0 and 1 is `true` in lua
  return fn.empty(fn.glob(vim.loop.cwd()..cfg_name)) ~= 1
end

-- helper for defining highlight groups
Util.set_hl = function(group, options)
  local bg = options.bg == nil and '' or 'guibg=' .. options.bg
  local fg = options.fg == nil and '' or 'guifg=' .. options.fg
  local gui = options.gui == nil and '' or 'gui=' .. options.gui
  local link = options.link or false
  local target = options.target

  if not link then
    vim.cmd(string.format('hi %s %s %s %s', group, bg, fg, gui))
  else
    vim.cmd(string.format('hi! link', group, target))
  end
end

-- might be useful
Util.spinner = function()
  local anim_frames = {
    "   ",
    "▪  ",
    "▪▪ ",
    "▪▪▪",
    "▬▪▪",
    "▬▬▪",
    "▬▬▬",
    "▪▬▬",
    "▪▪▬",
    "▪▪▪",
    " ▪▪",
    "  ▪",
    "   ",
  }

  local current_frame = 0
  local results_updated = function()
    current_frame = current_frame >= #anim_frames and 1 or current_frame + 1
    print(anim_frames[current_frame])
  end

  local timer = fn.timer_start(80, results_updated, {['repeat'] = 100})

  return timer
end

-- playing around with TS
Util.parse = function()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local parser = vim.treesitter.get_parser(0, "html")
  local ts_tree = parser:parse()[1]
  local query = vim.treesitter.parse_query("html", [[
(_
  (element
    (start_tag
      (attribute
        (quoted_attribute_value (attribute_value) @class
        (#eq? @class "question-hyperlink")))
    )
  )
  (element
    (start_tag
      (attribute
        (attribute_name) @title_tag
        (#eq? @title_tag "title"))
    )
  )
) @result ]])

  for pattern, match, metadata in query:iter_matches(ts_tree:root(), 0, 0, -1) do
    for id, node in pairs(match) do
      local name = query.captures[id]
      -- `node` was captured by the `name` capture in the match
      P(ts_utils.get_node_text(node))
    end
  end
end

return Util
