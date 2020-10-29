local hl = function(group, link)
  vim.cmd(string.format('hi link TS%s %s', group, link))
end

treesitter_hl = function()
  local highlights = {
    -- misc
    {'Error', 'GruvboxRed'},
    {'PunctDelimiter', 'GruvboxFg1'},
    {'PunctBracket', 'GruvboxOrange'},
    {'PunctSpecial', 'GruvboxOrange'},

    -- misc
    {'Constant', 'GruvboxPurple'},
    {'ConstBuiltin', 'GruvboxOrange'},
    {'ConstMacro', 'GruvboxAqua'}, -- idk
    {'String', 'GruvboxGreen'},
    {'StringEscape', 'GruvboxOrange'},
    {'Character', 'GruvboxGreen'},
    {'Number', 'GruvboxPurple'},
    {'Boolean', 'GruvboxPurple'},
    {'Float', 'GruvboxPurple'},
    {'Float', 'GruvboxPurple'},
    {'Annotation', 'GruvboxBlue'},
    {'Attribute', 'GruvboxAqua'},
    {'Namespace', 'GruvboxAqua'},

    -- functions
    {'FuncBuiltin', 'GruvboxAqua'},
    {'Function', 'GruvboxAqua'},
    {'FuncMacro', 'GruvboxAqua'},
    {'Parameter', 'GruvboxBlue'},
    {'ParameterReference', 'GruvboxBlue'},
    {'Method', 'GruvboxAqua'},
    {'Field', 'GruvboxFg1'},
    {'Property', 'GruvboxAqua'},
    {'Constructor', 'GruvboxBlue'},

    -- keywords
    {'Conditional', 'GruvboxRed'},
    {'Repeat', 'GruvboxRed'},
    {'Label', 'GruvboxRed'},
    {'Keyword', 'GruvboxOrange'},
    {'KeywordFunction', 'GruvboxRed'},
    {'Operator', 'GruvboxAqua'},
    {'Exception', 'GruvboxRed'},
    {'Type', 'GruvboxYellow'},
    {'TypeBuiltin', 'GruvboxYellow'},
    {'Structure', 'GruvboxAqua'},
    {'Include', 'GruvboxAqua'},

    -- variables
    {'Variable', 'GruvboxFg1'},
    {'VariableBuiltin', 'GruvboxBlue'},

    -- text
    {'Text', 'Normal'},
    {'Strong', 'GruvboxGreenBold'},
    {'Emphasis', 'Normal'},
    {'Underline', 'Normal'},
    {'Title', 'GruvboxGreenBold'},
    {'Literal', 'Normal'},
    {'URI', 'GruvboxOrange'},

    -- tags
    {'Tag', 'GruvboxBlue'},
    {'TagDelimiter', 'GruvboxAqua'},
  }

  for _, highlight in pairs(highlights) do
    hl(highlight[1], highlight[2])
  end
end
