local sections = require('el.sections')

local filename = function(_, buffer)
    local shortname = vim.fn.fnamemodify(buffer.name, ':t')
    return sections.highlight("Filetype", string.format(' %s ', shortname))
end

return filename
