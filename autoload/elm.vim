" functions for Elm (http://elm-lang.org/)
"
" Make the given file, or the current file if none is given.
function! elm#Make(...)
	let l:file = (a:0 == 0) ? expand("%") : a:1
	echo system("elm-make " . l:file)
endfunction

" Test the given file, or the current file with 'Test' added if none is given.
function! elm#Test(...)
	let l:file = (a:0 == 0) ? "Test" . expand("%") : a:1
	echo system("elm-test " . l:file)
endfunction

" Open the elm repl in a subprocess.
function! elm#Repl()
	!elm-repl
endfunction
