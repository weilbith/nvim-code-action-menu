if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

setlocal readonly
setlocal nomodifiable
setlocal bufhidden=wipe

nnoremap <buffer> <CR> <cmd>lua require('code_action_menu.menu_window').select_code_action()<CR>
nnoremap <buffer> <Esc> <cmd>close<CR>
nnoremap <buffer> q <cmd>close<CR>

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
