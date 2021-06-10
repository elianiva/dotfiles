syntax region mkdID matchgroup=mkdEscape start="\[" end="\]" oneline concealends
syntax region mkdURL matchgroup=mkdEscape start="(" end=")" contained oneline
syntax region mkdLink matchgroup=mkdEscape  start="\\\@<!!\?\[\ze[^]\n]*\n\?[^]\n]*\][[(]" end="\]" contains=mkdID,mkdURL nextgroup=mkdURL,mkdID skipwhite
hi def link mkdLine special
hi def link mkdID identifier
hi def link mkdURL underlined
