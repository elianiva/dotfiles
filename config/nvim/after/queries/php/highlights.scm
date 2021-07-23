[
  "->"
  "=>"
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
