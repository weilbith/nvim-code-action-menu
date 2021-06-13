syntax match CodeActionMenuDetailsTitle '\%1l.*$'
syntax keyword CodeActionMenuDetailsLabel Kind:
syntax keyword CodeActionMenuDetailsLabel Name:
syntax keyword CodeActionMenuDetailsLabel Preferred: nextgroup=CodeActionMenuDetailsPreferred skipwhite
syntax keyword CodeActionMenuDetailsLabel Disabled: nextgroup=CodeActionMenuDetailsDisabled skipwhite
syntax keyword CodeActionMenuDetailsLabel Changes:
syntax match CodeActionMenuDetailsPreferred 'yes' contained
syntax match CodeActionMenuDetailsDisabled 'yes.*' contained
syntax keyword CodeActionMenuDetailsUndefined undefined
syntax match CodeActionMenuDetailsCreatedFile '\*\S\+'
syntax match CodeActionMenuDetailsChangedFile '\~\S\+'
syntax match CodeActionMenuDetailsRenamedFile '\>\S\+'
syntax match CodeActionMenuDetailsDeletedFile '\!\S\+'
syntax match CodeActionMenuDetailsAddedLinesCount '+\d\+'
syntax match CodeActionMenuDetailsDeletedLinesCount '-\d\+'

highlight default link CodeActionMenuDetailsTitle             Title
highlight default link CodeActionMenuDetailsLabel             Label
highlight default link CodeActionMenuDetailsPreferred         DiffAdd
highlight default link CodeActionMenuDetailsDisabled          Error
highlight default link CodeActionMenuDetailsUndefined         Comment
highlight default link CodeActionMenuDetailsCreatedFile       DiffAdd
highlight default link CodeActionMenuDetailsChangedFile       DiffChange
highlight default link CodeActionMenuDetailsRenamedFile       DiffChange
highlight default link CodeActionMenuDetailsDeletedFile       DiffDelete
highlight default link CodeActionMenuDetailsAddedLinesCount   DiffAdd
highlight default link CodeActionMenuDetailsDeletedLinesCount DiffDelete
