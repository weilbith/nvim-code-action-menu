syntax match CodeActionMenuDetailsCreatedFile '\*\S\+'
syntax match CodeActionMenuDetailsChangedFile '\~\S\+'
syntax match CodeActionMenuDetailsRenamedFile '\>\S\+'
syntax match CodeActionMenuDetailsDeletedFile '\!\S\+'
syntax match CodeActionMenuDetailsAddedLinesCount '+\d\+'
syntax match CodeActionMenuDetailsDeletedLinesCount '-\d\+'

highlight default link CodeActionMenuDetailsCreatedFile       DiffAdd
highlight default link CodeActionMenuDetailsChangedFile       DiffChange
highlight default link CodeActionMenuDetailsRenamedFile       DiffChange
highlight default link CodeActionMenuDetailsDeletedFile       DiffDelete
highlight default link CodeActionMenuDetailsAddedLinesCount   DiffAdd
highlight default link CodeActionMenuDetailsDeletedLinesCount DiffDelete
highlight default link CodeActionMenuDetailsAddedSquares      CodeActionMenuDetailsAddedLinesCount
highlight default link CodeActionMenuDetailsDeletedSquares    CodeActionMenuDetailsDeletedLinesCount
highlight default link CodeActionMenuDetailsNeutralSquares    Comment
