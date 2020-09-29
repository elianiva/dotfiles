local sections = require("el.sections")

local gitstatus = function()
    local branch = vim.call("fugitive#head")
    if branch == "" then
        return sections.highlight("Git", "")
    else
        return sections.highlight("Git", string.format(" %s ", branch))
    end
end

return gitstatus
