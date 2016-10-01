let s:errors = []

fun! s:elmOracle(...)
	let project = finddir("elm-stuff/..", ".;")
	if len(project) == 0
		echoerr "`elm-stuff` not found! run `elm-package install` for autocomplete."
		return []
	endif

	let filename = expand("%:p")

	if a:0 == 0
		let oldiskeyword = &iskeyword
		" Some non obvious values used in 'iskeyword':
		"    @     = all alpha
		"    48-57 = numbers 0 to 9
		"    @-@   = character @
		"    124   = |
		setlocal iskeyword=@,48-57,@-@,_,-,~,!,#,$,%,&,*,+,=,<,>,/,?,.,\\,124,^
		let word = expand('<cword>')
		let &iskeyword = oldiskeyword
	else
		let word = a:1
	endif

	let infos = elm#Oracle(filename, word)
	if v:shell_error != 0
		call elm#util#EchoError("elm-oracle failed:\n\n", infos)
		return []
	endif

	let d = split(infos, '\n')
	if len(d) > 0
		return elm#util#DecodeJSON(d[0])
	endif

	return []
endf

" Vim command to format Elm files with elm-format
fun! elm#Format()
	" check for elm-format
	if elm#util#CheckBin("elm-format", "https://github.com/avh4/elm-format") == ""
		return
	endif

	" save cursor position, folds and many other things
	mkview!

	" write current unsaved buffer to a temporary file
	let l:tmpname = tempname() . ".elm"
	call writefile(getline(1, '$'), l:tmpname)

	" call elm-format on the temporary file
	let out = system("elm-format " . l:tmpname . " --output " . l:tmpname)

	" if there is no error
	if v:shell_error == 0
		try | silent undojoin | catch | endtry

		" replace current file with temp file, then reload buffer
		let old_fileformat = &fileformat
		call rename(l:tmpname, expand('%'))
		silent edit!
		let &fileformat = old_fileformat
		let &syntax = &syntax
	elseif g:elm_format_fail_silently == 0
		call elm#util#EchoLater("EchoError", "elm-format:", out)
	endif

	" restore our cursor/windows positions, folds, etc..
	silent! loadview
endf

" Query elm-oracle and echo the type and docs for the word under the cursor.
fun! elm#ShowDocs()
	" check for the elm-oracle binary
	if elm#util#CheckBin("elm-oracle", "https://github.com/elmcast/elm-oracle") == ""
		return
	endif

	let response = s:elmOracle()

	if len(response) > 0
		let info = response[0]
		redraws! | echohl Identifier | echon info.fullName | echohl None | echon " : " | echohl Function | echon info.signature | echohl None | echon "\n\n" . info.comment
	else
		call elm#util#Echo("elm-oracle:", "...no match found")
	endif
endf

" Query elm-oracle and open the docs for the word under the cursor.
fun! elm#BrowseDocs()
	" check for the elm-oracle binary
	if elm#util#CheckBin("elm-oracle", "https://github.com/elmcast/elm-oracle") == ""
		return
	endif

	let response = s:elmOracle()

	if len(response) > 0
		let info = response[0]
		call elm#util#OpenBrowser(info.href)
	else
		call elm#util#Echo("elm-oracle:", "...no match found")
	endif
endf


fun! elm#Syntastic(input)
	let fixes = []

	let bin = "elm-make"
	let format = "--report=json"
	let input = shellescape(a:input)
	let output = "--output=" . shellescape(syntastic#util#DevNull())
	let command = bin . " " . format  . " " . input . " " . output
	let reports = s:ExecuteInRoot(command)

	for report in split(reports, '\n')
		if report[0] == '['
            for error in elm#util#DecodeJSON(report)
                if g:elm_syntastic_show_warnings == 0 && error.type == "warning"
                else
                    if a:input == error.file
                        call add(fixes, {"filename": error.file,
                                    \"valid": 1,
                                    \"bufnr": bufnr('%'),
                                    \"type": (error.type == "error") ? 'E' : 'W',
                                    \"lnum": error.region.start.line,
                                    \"col": error.region.start.column,
                                    \"text": error.overview})
                    endif
                endif
            endfor
        endif
	endfor

	return fixes
endf

fun! elm#Build(input, output, show_warnings)
	let s:errors = []
	let fixes = []
	let rawlines = []

	let bin = "elm-make"
	let format = "--report=json"
	let input = shellescape(a:input)
	let output = "--output=" . shellescape(a:output)
	let command = bin . " " . format  . " " . input . " " . output
	let reports = s:ExecuteInRoot(command)

	for report in split(reports, '\n')
		if report[0] == '['
			for error in elm#util#DecodeJSON(report)
				if a:show_warnings == 0 && error.type == "warning"
				else
					call add(s:errors, error)
					call add(fixes, {"filename": error.file,
								\"valid": 1,
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

	let details = join(rawlines, "\n")
	let lines = split(details, "\n")
	if !empty(lines)
		let overview = lines[0]
	else
		let overview = ""
	endif

	if details == '' || details =~ '^Successfully.*'
	else
		call add(s:errors, {"overview": details, "details": details})
		call add(fixes, {"filename": expand('%', 1),
					\"valid": 1,
					\"type": 'E',
					\"lnum": 0,
					\"col": 0,
					\"text": overview})
	endif

	return fixes
endf

" Make the given file, or the current file if none is given.
fun! elm#Make(...)
	if elm#util#CheckBin("elm-make", "http://elm-lang.org/install") == ""
		return
	endif

	call elm#util#Echo("elm-make:", "building...")

	let input = (a:0 == 0) ? expand("%:p") : a:1
	let fixes = elm#Build(input, g:elm_make_output_file, g:elm_make_show_warnings)

	if len(fixes) > 0
		call elm#util#EchoWarning("", "found " . len(fixes) . " errors")

		call setqflist(fixes, 'r')
		cwindow

		if get(g:, "elm_jump_to_error", 1)
			ll 1
		endif
	else
		call elm#util#EchoSuccess("", "Sucessfully compiled")

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

" Open the elm repl in a subprocess.
fun! elm#Repl()
	" check for the elm-repl binary
	if elm#util#CheckBin("elm-repl", "http://elm-lang.org/install") == ""
		return
	endif

	if has('nvim')
		term("elm-repl")
	else
		!elm-repl
	endif
endf

function elm#Oracle(filepath, word)
	let bin = "elm-oracle"
	let filepath = shellescape(a:filepath)
	let word = shellescape(a:word)
	let command = bin . " " . filepath . " " . word
	return s:ExecuteInRoot(command)
endfunction

let s:fullComplete = ""

" Complete the current token using elm-oracle
fun! elm#Complete(findstart, base)
	if a:findstart
		let line = getline('.')

		let idx = col('.') - 1
		let start = 0
		while idx > 0 && line[idx - 1] =~ '[a-zA-Z0-9_\.]'
			if line[idx - 1] == "." && start == 0
				let start = idx
			endif
			let idx -= 1
		endwhile

		if start == 0
			let start = idx
		endif

		let s:fullComplete = line[idx : col('.')-2]

		return start
	else
		" check for the elm-oracle binary
		if elm#util#CheckBin("elm-oracle", "https://github.com/elmcast/elm-oracle") == ""
			return []
		endif

		let res = []
		let response = s:elmOracle(s:fullComplete)

		let detailed = get(g:, 'elm_detailed_complete', 0)

		for r in response
			let menu = ''
			if detailed
				let menu = ': ' . r.signature
			endif
			call add(res, {'word': r.name, 'menu': menu})
		endfor

		return res
	endif
endf

" If the current buffer contains a consoleRunner, run elm-test with it.
" Otherwise run elm-test in the root of your project which deafults to
" running 'elm-test tests/TestRunner'.
fun! elm#Test()
	if elm#util#CheckBin("elm-test", "https://github.com/rtfeldman/node-elm-test") == ""
		return
	endif

	if match(getline(1, '$'), "consoleRunner") < 0
		let out = s:ExecuteInRoot("elm-test")
		call elm#util#EchoSuccess("elm-test", out)
	else
		let filepath = shellescape(expand("%:p"))
		let out = s:ExecuteInRoot("elm-test " . filepath)
		call elm#util#EchoSuccess("elm-test", out)
	endif
endf

" Returns the closest parent with an elm-package.json file.
function! s:FindRootDirectory()
	let elm_root = getbufvar('%', 'elmRoot')
	if empty(elm_root)
		let current_file = expand('%:p')
		let dir_current_file = fnameescape(fnamemodify(current_file, ':h'))
		let match = findfile('elm-package.json', dir_current_file . ';')
		if empty(match)
			let elm_root = ''
		else
			let elm_root = fnamemodify(match, ':p:h')
		endif

		if !empty(elm_root)
			call setbufvar('%', 'elmRoot', elm_root)
		endif
	endif
	return elm_root
endfunction

" Executes a command in the project directory.
function! s:ExecuteInRoot(cmd) abort
	let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
	let current_dir = getcwd()
	let root_dir = s:FindRootDirectory()

	try
		execute cd . fnameescape(root_dir)
		let out = system(a:cmd)
	finally
		execute cd . fnameescape(current_dir)
	endtry

	return out
endfunction
