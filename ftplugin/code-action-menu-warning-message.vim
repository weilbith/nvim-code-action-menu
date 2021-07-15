runtime! ftplugin/code-action-menu.vim ftplugin/code-action-menu_*.vim ftplugin/code-action-menu/*.vim

augroup CodeActionMenuWarningMessage
  autocmd User CodeActionMenuWindowOpened ++once set winhighlight=FloatBorder:CodeActionMenuWarningMessageBorder
augroup END
