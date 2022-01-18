[
  "->"
  "=>"
  "::"
] @operator

(
  (qualified_name) @type
  (#match? @type "(string|bool|array|int)")
)

[
  "string"
  "int"
  "bool"
  "array"
] @type

(class_constant_access_expression
  (_)
  (name) @field)
