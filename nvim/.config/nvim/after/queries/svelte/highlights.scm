(tag_name) @tag
;(erroneous_end_tag_name) @error
(attribute_name) @property
(attribute_value) @string
(quoted_attribute_value) @string
(comment) @comment

[
  (special_block_keyword)
] @keyword

[
 "{"
 "}"
] @punctuation.bracket


[
 "<"
 ">"
 "</"
 "/>"
  "#"
  ":"
  "/"
] @tag.delimiter
