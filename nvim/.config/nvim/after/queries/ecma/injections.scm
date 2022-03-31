(assignment_expression
  (member_expression) @_inner-html
  (#lua-match? @_inner-html "innerHTML$")
  (template_string) @html
  (#offset! @html 0 1 0 -1))
