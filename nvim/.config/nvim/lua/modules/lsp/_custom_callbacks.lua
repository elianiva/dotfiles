--[[
  taken from https://github.com/glepnir/nvim
  big thanks to @glepnir
  none of this is mine :)
--]]

local lsp = vim.lsp
local window = require('modules.lsp._window')

lsp.callbacks['textDocument/hover'] = function(_, method, result)
  lsp.util.focusable_float(method, function()
      if not (result and result.contents) then return end
      local markdown_lines = lsp.util.convert_input_to_markdown_lines(result.contents)
      markdown_lines = lsp.util.trim_empty_lines(markdown_lines)
      if vim.tbl_isempty(markdown_lines) then return end

      local bufnr, contents_winid, _, border_winid = window.fancy_floating_markdown(markdown_lines)
      lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, contents_winid)
      lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, border_winid)
      return bufnr,contents_winid
  end)
end
