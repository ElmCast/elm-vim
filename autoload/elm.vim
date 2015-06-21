" functions for Elm (http://elm-lang.org/)

" Make the given file, or the current file if none is given.
function! elm#Make(...)
	if a:0 == 0
		echo system("elm-make ". expand("%"))
	else
		echo system("elm-make ". a:1)
	endif
endfunction

" Test the given file, or the current file with 'Test' added if none is given.
function! elm#Test(...)
	if a:0 == 0
		echo system("elm-test Test". expand("%"))
	else
		echo system("elm-test ". a:1)
	endif
endfunction

" Open the elm repl in a subprocess.
function! elm#Repl()
	!elm-repl
endfunction
