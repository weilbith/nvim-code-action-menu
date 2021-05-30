autocmd! WinClosed <buffer> lua require('code_action_menu.details_window').close_code_action_details_window() " To clear the internal window number state.
