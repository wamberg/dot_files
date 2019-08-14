" tab characters appear 4-spaces-wide
set tabstop=4 softtabstop=0 noexpandtab shiftwidth=4

" Format on save
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
