syntax match CodeActionMenuMenuIndex '^\s\[\d\+\]' nextgroup=CodeActionMenuMenuKind skipwhite
syntax match CodeActionMenuMenuKind '(\w\+)' contained nextgroup=CodeActionMenuMenuTitle skipwhite
syntax match CodeActionMenuMenuTitle '.*' contained
syntax match CodeActionMenuMenuDisabled '.*\[disabled\]'

highlight default link CodeActionMenuMenuIndex      Special
highlight default link CodeActionMenuMenuKind       Type
highlight default link CodeActionMenuMenuTitle      Normal
highlight default link CodeActionMenuMenuDisabled   Comment
highlight default link CodeActionMenuMenuSelection  QuickFixLine
