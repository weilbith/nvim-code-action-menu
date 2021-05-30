setlocal readonly
setlocal nomodifiable
setlocal bufhidden=wipe

nnoremap <buffer> <CR> <cmd>lua require('code_action_menu').execute_selected_code_action()<CR>
nnoremap <buffer> <Esc> <cmd>lua require('code_action_menu').close_code_action_menu()<CR>
nnoremap <buffer> q <cmd>lua require('code_action_menu').close_code_action_menu()<CR>

autocmd! CursorMoved <buffer> lua require('code_action_menu').update_code_action_details()
