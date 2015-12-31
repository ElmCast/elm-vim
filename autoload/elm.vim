fun! s:DecodeJSON(s)
  let true = 1
  let false = 0
  let null = 0
	return eval(a:s)
endf

function! s:IsWin()
	let win = ['win16', 'win32', 'win32unix', 'win64', 'win95']
	for w in win
		if (has(w))
			return 1
		endif
	endfor

	return 0
endfunction

function! s:get_browser_command()
    let elm_browser_command = get(g:, 'elm_browser_command', '')
    if elm_browser_command == ''
        if s:IsWin()
            let elm_browser_command = '!start rundll32 url.dll,FileProtocolHandler %URL%'
        elseif has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin'
            let elm_browser_command = 'open %URL%'
        elseif executable('xdg-open')
            let elm_browser_command = 'xdg-open %URL%'
        elseif executable('firefox')
            let elm_browser_command = 'firefox %URL% &'
        else
            let elm_browser_command = ''
        endif
    endif
    return elm_browser_command
endfunction

function! s:OpenBrowser(url)
    let cmd = s:get_browser_command()
    if len(cmd) == 0
        redraw
        echohl WarningMsg
        echo "It seems that you don't have general web browser. Open URL below."
        echohl None
        echo a:url
        return
    endif
    if cmd =~ '^!'
        let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
        silent! exec cmd
    elseif cmd =~ '^:[A-Z]'
        let cmd = substitute(cmd, '%URL%', '\=a:url', 'g')
        exec cmd
    else
        let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
        call system(cmd)
    endif
endfunction

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

	let infos = system("cd " . shellescape(project) . " && elm-oracle " . shellescape(filename) . " " . shellescape(word))
        if v:shell_error != 0
          echo "elm-oracle failed:\n\n" . infos
          return []
        endif

	let d = split(infos, '\n')
	if len(d) > 0
		return s:DecodeJSON(d[0])
	endif

	return []
endf

" Query elm-oracle and echo the type and docs for the word under the cursor.
fun! elm#ShowDocs()
		let response = s:elmOracle()
		if len(response) > 0
			let info = response[0]
			redraws! | echohl Identifier | echon info.fullName | echohl None | echon " : " | echohl Function | echon info.signature | echohl None | echon "\n\n" . info.comment
		else
			echon "elm-oracle: " | echohl Identifier |  echon "...no match found" | echohl None
		endif
endf

" Query elm-oracle and open the docs for the word under the cursor.
fun! elm#BrowseDocs()
		let response = s:elmOracle()
		if len(response) > 0
			let info = response[0]
			call s:OpenBrowser(info.href)	
		else
			echon "elm-oracle: " | echohl Identifier |  echon "...no match found" | echohl None
		endif
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
