" plugin for Elm (http://elm-lang.org/)

if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

" Make the given file, or the current file if none is given.
function! ElmMake(...)
	if a:0 == 0
		echo system("elm-make ". expand("%"))
	else
		echo system("elm-make ". a:1)
	endif
endfunction

" Test the given file, or the current file with 'Test' added if none is given.
function! ElmTest(...)
	if a:0 == 0
		echo system("elm-test Test". expand("%"))
	else
		echo system("elm-test ". a:1)
	endif
endfunction

" Open the elm repl in a subprocess.
function! ElmRepl()
	!elm-repl
endfunction

" Commands
command -buffer -nargs=? -complete=file ElmMake call ElmMake(<f-args>)
command -buffer ElmMakeMain call ElmMake("Main.elm")
command -buffer -nargs=? -complete=file ElmTest call ElmTest(<f-args>)
command -buffer ElmRepl call ElmRepl()

" Mappings
nnoremap <silent> <Plug>(elm-make) :<C-u>call ElmMake()<CR>
nnoremap <silent> <Plug>(elm-make-main) :<C-u>call ElmMake("Main.elm")<CR>
nnoremap <silent> <Plug>(elm-test) :<C-u>call ElmTest()<CR>
nnoremap <silent> <Plug>(elm-repl) :<C-u>call ElmRepl()<CR>
