" IsWin returns 1 if current OS is Windows or 0 otherwise
fun! elm#util#IsWin()
	let win = ['win16', 'win32', 'win32unix', 'win64', 'win95']
	for w in win
		if (has(w))
			return 1
		endif
	endfor

	return 0
endf

fun! elm#util#CheckBin(bin, url)
	let binpath = substitute(a:bin, '^\s*\(.\{-}\)\s*$', '\1', '')

    if executable(binpath)
        return binpath
    endif

	call elm#util#EchoWarning("elm-vim:", "could not find " . binpath . " [" . a:url . "]")

	return ""
endf

" Determines the browser command to use
fun! s:get_browser_command()
    let elm_browser_command = get(g:, 'elm_browser_command', '')
    if elm_browser_command == ''
        if elm#util#IsWin()
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
endf

" OpenBrowser opens a url in the default browser
fun! elm#util#OpenBrowser(url)
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
endf

" DecodeJSON decodes a string of json into a viml object
fun! elm#util#DecodeJSON(s)
  let true = 1
  let false = 0
  let null = 0
	return eval(a:s)
endf

" Print functions
fun! elm#util#Echo(title, msg)
	redraws! | echon a:title . " " | echohl Identifier | echon a:msg | echohl None
endf

fun! elm#util#EchoSuccess(title, msg)
	redraws! | echon a:title . " " | echohl Function | echon a:msg | echohl None
endf

fun! elm#util#EchoWarning(title, msg)
	redraws! | echon a:title . " " | echohl WarningMsg | echon a:msg | echohl None
endf

fun! elm#util#EchoError(title, msg)
	redraws! | echon a:title . " " | echohl ErrorMsg | echon a:msg | echohl None
endf
