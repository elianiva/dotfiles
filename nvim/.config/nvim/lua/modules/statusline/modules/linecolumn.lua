local builtin = require("el.builtin")
local sections = require("el.sections")

local line_col = sections.highlight("LineCol", string.format(' Ln %s, Col, %s ', builtin.line, builtin.column))

return line_col
