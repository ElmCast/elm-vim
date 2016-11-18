" syntastic syntax checker

if exists('g:loaded_syntastic_elm_elm_make_checker')
    finish
endif
let g:loaded_syntastic_elm_elm_make_checker = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

function! SyntaxCheckers_elm_elm_IsAvailable() dict
	return executable(substitute('elm-make', '^\s*\(.\{-}\)\s*$', '\1', ''))
endfunction

function! SyntaxCheckers_elm_elm_make_GetLocList() dict
    return elm#Syntastic(expand('%:p'))
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
			\ 'filetype': 'elm',
			\ 'name': 'elm_make',
			\ 'exec': 'elm-make'})

let &cpoptions = s:save_cpo
unlet s:save_cpo
