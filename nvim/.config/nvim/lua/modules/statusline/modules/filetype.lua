local sections = require('el.sections')

local filetype = function()
    local filetype = vim.o.filetype
    if filetype == '' then
        return ''
    else
        return sections.highlight("Filetype", string.format('| %s ', filetype))
    end
end

return filetype
