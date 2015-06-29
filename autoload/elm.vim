fun! s:DecodeJSON(s)
  let true = 1
  let false = 0
  let null = 0
	return eval(a:s)
endf

" Make the given file, or the current file if none is given.
function! elm#Make(...)
	echon "elm-make: " | echohl Identifier | echon "building ..."| echohl None

	let filename = (a:0 == 0) ? expand("%") : a:1
	let rawout = system("elm-make --report=json " . filename)
	let output = split(rawout, '\n')[0]
	let s:errors = []

	if output[0] == '['
		let s:errors = s:DecodeJSON(output)
		let errors = []
		for err in s:errors
			call add(errors, {"filename": err.file,
				      \"type": (err.type == "error") ? 'E' : 'W',
							\"lnum": err.region.start.line,
							\"col": err.region.start.column,
							\"text": err.overview})
		endfor

		let message = "found " . len(errors) . " errors"
		redraws! | echon " " | echohl Function | echon message  | echohl None

		call setqflist(errors, 'r')
		cwindow

		if get(g:, "elm_jump_to_error", 1)
			cc 1
		endif
	else
		call setqflist([])
		cwindow

		redraws! | echon " " | echohl Function | echon output | echohl None
	endif
endfunction

" Show the detail of the current error in the quickfix window.
function! elm#ErrorDetail()
	if !empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") ==# "quickfix"'))
		exec ":copen"
		let linenr = line(".")
		exec ":wincmd p"
		if len(s:errors) > 0
			echo s:errors[linenr-1].details
		endif
	endif
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
