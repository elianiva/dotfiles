--[[
  taken from https://github.com/glepnir/nvim
  big thanks to @glepnir
  none of this is mine :)
--]]

local window = require('modules.lsp._window')

vim.lsp.callbacks['textDocument/hover'] = function(_, method, result)
  vim.lsp.util.focusable_float(method, function()
      if not (result and result.contents) then return end
      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
      if vim.tbl_isempty(markdown_lines) then return end

      local bufnr, contents_winid, _, border_winid = window.fancy_floating_markdown(markdown_lines)
      vim.lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, contents_winid)
      vim.lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, border_winid)
      return bufnr,contents_winid
  end)
end
