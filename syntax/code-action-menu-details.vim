syntax match CodeActionMenuDetailsTitle '\%1l.*$'
syntax keyword CodeActionMenuDetailsLabel Kind:
syntax keyword CodeActionMenuDetailsLabel Name:
syntax keyword CodeActionMenuDetailsLabel Preferred: nextgroup=CodeActionMenuDetailsPreferred skipwhite
syntax keyword CodeActionMenuDetailsLabel Disabled: nextgroup=CodeActionMenuDetailsDisabled skipwhite
syntax match CodeActionMenuDetailsPreferred 'yes' contained
syntax match CodeActionMenuDetailsDisabled 'yes.*' contained
syntax keyword CodeActionMenuDetailsUndefined undefined

highlight default link CodeActionMenuDetailsTitle     Title
highlight default link CodeActionMenuDetailsLabel     Label
highlight default link CodeActionMenuDetailsPreferred DiffAdd
highlight default link CodeActionMenuDetailsDisabled  Error
highlight default link CodeActionMenuDetailsUndefined Comment
