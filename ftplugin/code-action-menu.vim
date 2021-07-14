let b:undo_ftplugin = 'setlocal'

setlocal readonly
let b:undo_ftplugin .= ' readonly<'

setlocal nomodifiable
let b:undo_ftplugin .= ' modifiable<'

setlocal bufhidden=wipe
let b:undo_ftplugin .= ' bufhidden<'
