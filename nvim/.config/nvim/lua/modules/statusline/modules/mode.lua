local sections = require("el.sections")

local modes = {
   n      = {'Normal', 'N', 'NormalMode'},
   no     = {'N·OpPd', '?', 'OpPending' },
   v      = {'Visual', 'V', 'VisualMode'},
   V      = {'V·Line', 'Vl', 'VisualLineMode'},
   [''] = {'V·Blck', 'Vb' },
   s      = {'Select', 'S' },
   S      = {'S·Line', 'Sl' },
   [''] = {'S·Block', 'Sb' },
   i      = {'Insert', 'I', 'InsertMode'},
   ic     = {'ICompl', 'Ic', 'ComplMode'},
   R      = {'Replace', 'R', 'ReplaceMode'},
   Rv     = {'VRplce', 'Rv' },
   c      = {'Command', 'C', 'CommandMode'},
   cv     = {'Vim Ex', 'E' },
   ce     = {'Ex (r)', 'E' },
   r      = {'Prompt', 'P' },
   rm     = {'More  ', 'M' },
   ['r?'] = {'Confirm', 'Cn'},
   ['!']  = {'Shell ', 'S'},
   t      = {'Term  ', 'T', 'TerminalMode'},
}

local mode = function(_, buffer)
    local mode = vim.api.nvim_get_mode().mode
    local display_name = modes[mode][1]

    return sections.highlight("Mode", string.format(' %s ', display_name))
end

return mode
