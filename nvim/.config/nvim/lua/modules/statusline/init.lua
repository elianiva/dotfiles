local extensions = require("el.extensions")
local sections = require("el.sections")
local mode = require("modules.statusline.modules.mode")
local gitstatus = require("modules.statusline.modules.gitstatus")
local filename = require("modules.statusline.modules.filename")
local filetype = require("modules.statusline.modules.filetype")
local line_col = require("modules.statusline.modules.linecolumn")

local generator = function()
    return {
        mode, gitstatus, extensions.git_changes,
        sections.highlight("Base", sections.split),
        "%m", filename, filetype, line_col,
    }
end

-- And then when you're all done, just call
require('el').setup { generator = generator }
