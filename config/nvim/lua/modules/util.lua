local fn, api = vim.fn, vim.api

_G.Util = {}

P = function(stuff)
  print(vim.inspect(stuff))
  return stuff
end

Util.trigger_completion = function()
  local prev_col, next_col = fn.col "." - 1, fn.col "."
  local prev_char = fn.getline("."):sub(prev_col, prev_col)
  local next_char = fn.getline("."):sub(next_col, next_col)

  -- minimal autopairs-like behaviour

  if prev_char == "{" and next_char ~= "}" then
    return Util.t "<CR>}<C-o>O"
  end
  if prev_char == "[" and next_char ~= "]" then
    return Util.t "<CR>]<C-o>O"
  end
  if prev_char == "(" and next_char ~= ")" then
    return Util.t "<CR>)<C-o>O"
  end
  if prev_char == ">" and next_char == "<" then
    return Util.t "<CR><C-o>O"
  end -- html indents
  if prev_char == "(" and next_char == ")" then
    return Util.t "<CR><C-o>O"
  end -- flutter indents

  return Util.t "<CR>"
end

local to_rgb = function(hex)
  if #hex == 9 then
    local _, r, g, b, a = hex:match "(.)(..)(..)(..)(..)"
    return string.format(
      "rgba(%s, %s, %s, %s)",
      tonumber("0x" .. r),
      tonumber("0x" .. g),
      tonumber("0x" .. b),
      tonumber("0x" .. a)
    )
  end

  local _, r, g, b = hex:match "(.)(..)(..)(..)"
  return string.format(
    "rgb(%s, %s, %s)",
    tonumber("0x" .. r),
    tonumber("0x" .. g),
    tonumber("0x" .. b)
  )
end

local to_hex = function(rgb)
  if #rgb >= 16 then
    local r, g, b, a = rgb:match "%((%d+),%s(%d+),%s(%d+),%s(%d+)"
    return string.format("#%x%x%x%x", r, g, b, a)
  end

  local r, g, b = rgb:match "%((%d+),%s(%d+),%s(%d+)"
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
    return print "Not Supported!"
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

Util.t = function(cmd)
  return api.nvim_replace_termcodes(cmd, true, true, true)
end

Util.borders = {
  -- fancy border
  { "🭽", "FloatBorder" },
  { "▔", "FloatBorder" },
  { "🭾", "FloatBorder" },
  { "▕", "FloatBorder" },
  { "🭿", "FloatBorder" },
  { "▁", "FloatBorder" },
  { "🭼", "FloatBorder" },
  { "▏", "FloatBorder" },

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

Util.lsp_on_init = function(client)
  vim.notify(client.name .. ": Language Server Client successfully started!", "info")
end

Util.lsp_on_attach = function(client)
  if client.name == "svelte" or client.name == "volar" then
    client.resolved_capabilities.document_formatting = false
  end

  if client.name == "tsserver" then
    client.resolved_capabilities.document_formatting = false
    local ts_utils = require "nvim-lsp-ts-utils"
    ts_utils.setup {
      auto_inlay_hints = false, -- enable this once #9496 got merged
      enable_import_on_completion = true,
    }
    ts_utils.setup_client(client)
  end

  if client.resolved_capabilities.code_lens then
    vim.cmd [[
    augroup CodeLens
      au!
      au InsertEnter,InsertLeave * lua vim.lsp.codelens.refresh()
    augroup END
    ]]
  end

  if client.resolved_capabilities.document_highlight then
    vim.cmd [[
      autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    ]]
  end

  require("modules.lsp.mappings").lsp_mappings()
end

return Util
