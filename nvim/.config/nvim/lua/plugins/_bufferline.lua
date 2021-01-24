-- originally was taken from https://github.com/cooper-anderson/dotfiles
-- with some modifications and refactoring that I did

vim.cmd[[packadd nvim-bufferline.lua]]

local options = {
  show_buffer_close_icons = false,
  separator_style = {"", ""},
  diagnostics = "nvim_lsp",
  buffer_close_icon= '',
}

local function get_diagnostics_count()
  local error = vim.lsp.diagnostic.get_count(0, [[Error]])
  local warning = vim.lsp.diagnostic.get_count(0, [[Warning]])
  local information = vim.lsp.diagnostic.get_count(0, [[Information]])
  local hint = vim.lsp.diagnostic.get_count(0, [[Hint]])

  return error, warning, information, hint
end

function _G.nvim_diagnostics_tab()
  local bufferline = _G.nvim_bufferline()
  bufferline = string.sub(bufferline, 1, #bufferline - 16)

  local _, tabstart = string.find(bufferline, "Fill#%%=")
  local tabline = string.sub(bufferline, tabstart + 1)

  bufferline = string.sub(bufferline, 1, tabstart)

  local err, warn, info, hint = get_diagnostics_count()
  local prefix = "%#Tabline"

  if #tabline ~= 0 then
    prefix = "%#Tabline"
  end

  local diagnostics = ""

  local format_sign = function(hl_group, count)
    return string.format("%s%s%s%s", diagnostics, prefix, hl_group, count)
  end

  if hint ~= 0 then
    diagnostics = format_sign("Hint# ﬤ ", hint)
  end
  if info ~= 0 then
    diagnostics = format_sign("Information#  ", info)
  end
  if warn ~= 0 then
    diagnostics = format_sign("Warning#  ", warn)
  end
  if err ~= 0 then
    diagnostics = format_sign("Error#  ", err)
  end

  if err + warn + info + hint == 0 then
    diagnostics = format_sign("Success#  ", "")
  end

  return bufferline .. tabline .. "#" .. diagnostics
end

require("bufferline").setup{
  options = options,
}

vim.o.tabline = "%!v:lua.nvim_diagnostics_tab()"
