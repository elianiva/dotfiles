vim.cmd[[packadd nvim-bufferline.lua]]

require'bufferline'.setup{
  options = {
    view = "default",
    numbers = "none",
    separator_style = {'', ''}
  }
}
