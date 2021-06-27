syntax region mkdID matchgroup=mkdEscape start="\[" end="\]" oneline concealends
syntax region mkdURL matchgroup=mkdEscape start="(" end=")" contained oneline
syntax region mkdCode matchgroup=mkdEscape start="`" end="`" oneline concealends
syntax region mkdURI matchgroup=mkdEscape  start="\\\@<!!\?\[\ze[^]\n]*\n\?[^]\n]*\][[(]" end="\]" contains=mkdID,mkdURL nextgroup=mkdURL,mkdID skipwhite
syntax match mkdUnderline /─*$/
syntax match mkdLeftAngle /&lt;/ conceal cchar=<
syntax match mkdRightAngle /&gt;/ conceal cchar=>

hi def link mkdLine special
hi def link mkdID markdownLinkText
hi def link mkdURI markdownLinkText
hi def link mkdURL markdownURL
hi def link mkdCode markdownCode
