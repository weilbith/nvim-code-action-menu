setlocal readonly
setlocal nomodifiable
setlocal bufhidden=wipe

nnoremap <buffer> <CR> <cmd>lua require('code_action_menu').execute_selected_code_action()<CR>
nnoremap <buffer> <Esc> <cmd>lua require('code_action_menu.menu_window').close_code_action_menu_window()<CR>
nnoremap <buffer> q <cmd>lua require('code_action_menu.menu_window').close_code_action_menu_window()<CR>

autocmd! CursorMoved <buffer> lua require('code_action_menu.details_window').open_or_update_code_action_details_window()
autocmd! WinClosed <buffer> lua require('code_action_menu.menu_window').close_code_action_menu_window() " To clear the internal window number state.
