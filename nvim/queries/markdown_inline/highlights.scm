; Custom markdown_inline highlights based on upstream nvim-treesitter query.
;
; Difference from upstream: link brackets, destinations, and URLs are only
; highlighted (@markup.link) and NOT concealed, so links always show in full
; as [text](url) / ![alt](src) instead of collapsing to just `text`.
; (render-markdown.nvim sets conceallevel=3, which would otherwise hide them
; even with `link = { enabled = false }`.)
;
; Upstream source: nvim-treesitter runtime queries/markdown_inline/highlights.scm
; (MDeiml/tree-sitter-markdown). If highlighting looks stale after a parser
; update, re-diff against a fresh copy and re-apply the "no conceal on links"
; change below.
;
; NOTE: this file must stay a base query (no `; extends` modeline) inside the
; config's queries/ dir so it takes precedence over the bundled query.

(code_span) @markup.raw @nospell

(emphasis) @markup.italic

(strong_emphasis) @markup.strong

(strikethrough) @markup.strikethrough

(shortcut_link
  (link_text) @nospell)

; Conceal backslash in backslash escapes
((backslash_escape) @conceal
  (#offset! @conceal 0 0 0 -1)
  (#set! conceal ""))

; Conceal backslash in hard line breaks
((hard_line_break
  "\\" @conceal)
  (#set! conceal ""))

; Conceal codeblock and text style markers
([
  (code_span_delimiter)
  (emphasis_delimiter)
] @conceal
  (#set! conceal ""))

; Highlight (but do not conceal) inline links so they render as [text](url)
(inline_link
  [
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link)

[
  (link_label)
  (link_text)
  (link_title)
  (image_description)
] @markup.link.label

((inline_link
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

((image
  (link_destination) @_url) @_label
  (#set! @_label url @_url))

; Highlight (but do not conceal) image links so they render as ![alt](src)
(image
  [
    "!"
    "["
    "]"
    "("
    (link_destination)
    ")"
  ] @markup.link)

; Highlight (but do not conceal) full reference links
(full_reference_link
  [
    "["
    "]"
    (link_label)
  ] @markup.link)

; Highlight (but do not conceal) collapsed reference links
(collapsed_reference_link
  [
    "["
    "]"
  ] @markup.link)

; Highlight (but do not conceal) shortcut links
(shortcut_link
  [
    "["
    "]"
  ] @markup.link)

[
  (link_destination)
  (uri_autolink)
  (email_autolink)
] @markup.link.url @nospell

((uri_autolink) @_url
  (#offset! @_url 0 1 0 -1)
  (#set! @_url url @_url))

(entity_reference) @nospell

; Replace common HTML entities.
((entity_reference) @character.special
  (#eq? @character.special "&nbsp;")
  (#set! conceal " "))

((entity_reference) @character.special
  (#eq? @character.special "&lt;")
  (#set! conceal "<"))

((entity_reference) @character.special
  (#eq? @character.special "&gt;")
  (#set! conceal ">"))

((entity_reference) @character.special
  (#eq? @character.special "&amp;")
  (#set! conceal "&"))

((entity_reference) @character.special
  (#eq? @character.special "&quot;")
  (#set! conceal "\""))

((entity_reference) @character.special
  (#any-of? @character.special "&ensp;" "&emsp;")
  (#set! conceal " "))
