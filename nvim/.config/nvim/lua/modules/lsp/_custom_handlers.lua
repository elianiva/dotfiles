--[[
  taken from https://github.com/glepnir/nvim
  modified a bit
  big thanks to @glepnir
--]]

local lsp = vim.lsp
local window = require('modules.lsp._window')

lsp.handlers['textDocument/hover'] = function(_, method, result)
  lsp.util.focusable_float(method, function()
      if not (result and result.contents) then return end
      local markdown_lines = lsp.util.convert_input_to_markdown_lines(result.contents)
      markdown_lines = lsp.util.trim_empty_lines(markdown_lines)
      if vim.tbl_isempty(markdown_lines) then return end

      local opts = { max_width = 80 }

      local bufnr, contents_winid, _, border_winid = window.fancy_floating_markdown(markdown_lines, opts)
      lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, contents_winid)
      lsp.util.close_preview_autocmd({"CursorMoved", "BufHidden", "InsertCharPre"}, border_winid)
      return bufnr,contents_winid
  end)
end
