local job_ok, Job = pcall(require, "plenary.job")
local fn, api = vim.fn, vim.api

_G.Util = {}

P = function(stuff)
  print(vim.inspect(stuff))
  return stuff
end

Util.trigger_completion = function()
  if
    fn.pumvisible() ~= 0
    and fn.complete_info()["selected"] ~= -1
  then
    return fn["compe#confirm"]()
  end

  local prev_col, next_col = fn.col(".") - 1, fn.col(".")
  local prev_char = fn.getline("."):sub(prev_col, prev_col)
  local next_char = fn.getline("."):sub(next_col, next_col)

  -- handle indent
  -- html indents
  if prev_char == ">" and next_char == "<" then return Util.t("<CR><C-o>O") end

  return Util.t("<CR><C-R>=enwise#close()<CR>")
end

local to_rgb = function(hex)
  if #hex == 9 then
    local _, r, g, b, a = hex:match("(.)(..)(..)(..)(..)")
    return string.format(
      "rgba(%s, %s, %s, %s)",
      tonumber("0x" .. r),
      tonumber("0x" .. g),
      tonumber("0x" .. b),
      tonumber("0x" .. a)
    )
  end

  local _, r, g, b = hex:match("(.)(..)(..)(..)")
  return string.format(
    "rgb(%s, %s, %s)",
    tonumber("0x" .. r),
    tonumber("0x" .. g),
    tonumber("0x" .. b)
  )
end

local to_hex = function(rgb)
  if #rgb >= 16 then
    local r, g, b, a = rgb:match("%((%d+),%s(%d+),%s(%d+),%s(%d+)")
    return string.format("#%x%x%x%x", r, g, b, a)
  end

  local r, g, b = rgb:match("%((%d+),%s(%d+),%s(%d+)")
  return string.format("#%x%x%x", r, g, b)
end

-- convert colours
Util.convert_colour = function(mode)
  local result

  if mode == "rgb" then
    result = to_rgb(Util.get_word())
  elseif mode == "hex" then
    result = to_hex(Util.get_word())
  else
    return print("Not Supported!")
  end

  vim.cmd(string.format("s/%s/%s", Util.get_word(), result))
end

vim.cmd [[
  command! -nargs=? -range=% ToRgb call v:lua.Util.convert_color('rgb')
  command! -nargs=? -range=% ToHex call v:lua.Util.convert_color('hex')
]]

Util.get_word = function()
  local first_line, last_line = fn.getpos("'<")[2], fn.getpos("'>")[2]
  local first_col, last_col = fn.getpos("'<")[3], fn.getpos("'>")[3]
  return fn.getline(first_line, last_line)[1]:sub(first_col, last_col)
end

-- translate selected word, useful for when I do jp assignments
Util.translate = function(lang)
  if not job_ok then return end

  lang = lang or "en"
  local word = Util.get_word()
  local job = Job:new {
    command = "trans",
    args    = { "-b", ":" .. lang, word },
  }

  local ok, result = pcall(function()
    return vim.trim(job:sync()[1])
  end)

  -- if ok then return print(result) end
  if ok then
    vim.lsp.handlers["textDocument/hover"](nil, "textDocument/hover", {
      contents = {
        "Translate to ["..lang.."]:",
        string.rep("─", #result),
        "",
        result
      }
    })
    -- return print(result)
    return
  end
  print("Failed to translate.")
end
vim.cmd [[command! -range -nargs=* Translate call v:lua.Util.translate(<f-args>)]]

Util.t = function(cmd)
  return api.nvim_replace_termcodes(cmd, true, true, true)
end

Util.borders = {
  -- fancy border
  -- 0001fb7d
  {"🭽", "FloatBorder"},
  {"▔", "FloatBorder"},
  {"🭾", "FloatBorder"},
  {"▕", "FloatBorder"},
  {"🭿", "FloatBorder"},
  {"▁", "FloatBorder"},
  {"🭼", "FloatBorder"},
  {"▏", "FloatBorder"},

  -- padding border
  -- {"▄", "Bordaa"},
  -- {"▄", "Bordaa"},
  -- {"▄", "Bordaa"},
  -- {"█", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"▀", "Bordaa"},
  -- {"█", "Bordaa"}
}

Util.lsp_on_attach = function()
  require("modules.lsp._mappings").lsp_mappings()
end

Util.lsp_on_init = function()
  print("Language Server Client successfully started!")
end

return Util
