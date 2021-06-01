syntax match CodeActionMenuMenuIndex '^\s\[\d\+\]' nextgroup=CodeActionMenuMenuKind skipwhite
syntax match CodeActionMenuMenuKind '(\w\+)' contained nextgroup=CodeActionMenuMenuTitle skipwhite
syntax match CodeActionMenuMenuTitle '.*' contained

highlight default link CodeActionMenuMenuIndex  Special
highlight default link CodeActionMenuMenuKind   Type
highlight default link CodeActionMenuMenuTitle  Normal
highlight default link CodeActionMenuSelection  QuickFixLine
