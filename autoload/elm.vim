fun! s:DecodeJSON(s)
  let true = 1
  let false = 0
  let null = 0
	return eval(a:s)
endf

" Make the given file, or the current file if none is given.
fun! elm#Make(...)
	echon "elm-make: " | echohl Identifier | echon "building ..."| echohl None

	let filename = (a:0 == 0) ? expand("%") : a:1
	let reports = system("elm-make --report=json " . filename . " --output=". g:elm_make_output_file)

	let s:errors = []
	let fixes = []
	let rawlines = []

	" Parse reports into errors and raw lines of text.
	" Save error reports for use with ErrorDetails.
	for report in split(reports, '\n')
		if report[0] == '['
			for error in s:DecodeJSON(report)
				" Filter out warnings if user only wants to see errors.
				if g:elm_make_show_warnings == 0 && error.type == "warning"
				else
					call add(s:errors, error)
					call add(fixes, {"filename": error.file,
								\"type": (error.type == "error") ? 'E' : 'W',
								\"lnum": error.region.start.line,
								\"col": error.region.start.column,
								\"text": error.overview})
				endif
			endfor
		else
			call add(rawlines, report)
		endif
	endfor

	" Echo messages and add fixes to the quickfix window.
	if len(fixes) > 0
		let message = "found " . len(fixes) . " errors"
		redraws! | echon " " | echohl Function | echon message | echohl None

		call setqflist(fixes, 'r')
		cwindow

		if get(g:, "elm_jump_to_error", 1)
			cc 1
		endif
	else
		let message = join(rawlines, "\n")
		redraws! | echon " " | echohl Function | echon message | echohl None

		call setqflist([])
		cwindow
	endif
endf

" Show the detail of the current error in the quickfix window.
fun! elm#ErrorDetail()
	if !empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") ==# "quickfix"'))
		exec ":copen"
		let linenr = line(".")
		exec ":wincmd p"
		if len(s:errors) > 0
			let detail = s:errors[linenr-1].details
			if detail == ""
				let detail = s:errors[linenr-1].overview
			endif
			echo detail
		endif
	endif
endf

" Test the given file, or the current file with 'Test' added if none is given.
fun! elm#Test(...)
	let l:file = (a:0 == 0) ? "Test" . expand("%") : a:1
	echo system("elm-test " . l:file)
endf

" Open the elm repl in a subprocess.
fun! elm#Repl()
	!elm-repl
endf
