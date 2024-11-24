require("config.lazy")
require("config.options")
require("config.mappings")
require("config.lsp")

-- set current directory
vim.cmd([[
  au VimEnter * cd %:p:h

  " highlight yanked text for 250ms
  augroup Yank
    au!
    au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250, higroup = "Visual" }
  augroup END

  " Remove trailing whitespace on save
  let g:strip_whitespace = v:true
  augroup Whitespace
    au!
    au BufWritePre * if g:strip_whitespace | %s/\s\+$//e
  augroup END

  " automatically go to insert mode on terminal buffer
  autocmd BufEnter term://* startinsert
]])

-- prevent typo when pressing `wq` or `q`
vim.cmd([[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]])

-- for some reason vim-zig adds autoformatting on save
vim.g.zig_fmt_autosave = false

vim.diagnostic.config({
  float = {
    border = "single",
    severity_sort = true,
  },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
		},
	},
})
