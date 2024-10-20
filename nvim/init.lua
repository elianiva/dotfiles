require("config.lazy")
require("config.options")
require("config.mappings")
require("config.lsp")

-- set current directory
vim.cmd [[
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
]]

 -- stolen from tjdevries
vim.opt.formatoptions = vim.opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  - "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

