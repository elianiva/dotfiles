(tag_name) @tag
;(erroneous_end_tag_name) @error
(attribute_name) @property
(attribute_value) @string
(quoted_attribute_value) @string
(comment) @comment

[
  (if_tag)
  (else_tag)
  (each_tag)
] @keyword

[
 "{"
 "}"
] @punctuation.bracket

"=" @operator

[
 "<"
 ">"
 "</"
 "/>"
 "{#"
 "{:"
 "{/"
] @tag.delimiter
