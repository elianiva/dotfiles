local set_hl = require("modules._util").set_hl

ColorUtil = {}

-- italicize comments
set_hl("Comment", { gui = "italic" })

-- set colourscheme
-- require('lush')(require('lush_theme.gruvy'))
require('lush')(require('lush_theme.icy'))
