command! CodeActionMenu lua require('code_action_menu').open_code_action_menu()

" These behave differently only for COC users
function! s:CodeActionFromSelected(type)
  call luaeval("require('code_action_menu').open_code_action_menu(_A)", a:type)
endfunction

vnoremap <Plug>(codeaction-selected-menu)    <CMD>call luaeval("require('code_action_menu').open_code_action_menu(_A)", visualmode())<CR>
nnoremap <Plug>(codeaction-selected-menu)    <CMD>set operatorfunc=<SID>CodeActionFromSelected<CR>g@
nnoremap <Plug>(codeaction-menu)             <CMD>require('code_action_menu').open_code_action_menu('')<CR>
nnoremap <Plug>(codeaction-line-menu)        <CMD>require('code_action_menu').open_code_action_menu('line')<CR>
nnoremap <Plug>(codeaction-cursor-menu)      <CMD>require('code_action_menu').open_code_action_menu('cursor')CR>
