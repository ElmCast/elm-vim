" IsWin returns 1 if current OS is Windows or 0 otherwise
fun! elm#util#IsWin() abort
  let l:win = ['win16', 'win32', 'win32unix', 'win64', 'win95']
  for l:w in l:win
    if (has(l:w))
      return 1
    endif
  endfor

  return 0
endf

fun! elm#util#CheckBin(bin, url) abort
  let l:binpath = substitute(a:bin, '^\s*\(.\{-}\)\s*$', '\1', '')

  if executable(l:binpath)
    return l:binpath
  endif

  call elm#util#EchoWarning('elm-vim:', 'could not find ' . l:binpath . ' [' . a:url . ']')

  return ''
endf

" Determines the browser command to use
fun! s:get_browser_command() abort
  let l:elm_browser_command = get(g:, 'elm_browser_command', '')
  if l:elm_browser_command ==? ''
    if elm#util#IsWin()
      let l:elm_browser_command = '!start rundll32 url.dll,FileProtocolHandler %URL%'
    elseif has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin'
      let l:elm_browser_command = 'open %URL%'
    elseif executable('xdg-open')
      let l:elm_browser_command = 'xdg-open %URL%'
    elseif executable('firefox')
      let l:elm_browser_command = 'firefox %URL% &'
    else
      let l:elm_browser_command = ''
    endif
  endif
  return l:elm_browser_command
endf

" OpenBrowser opens a url in the default browser
fun! elm#util#OpenBrowser(url) abort
  let l:cmd = s:get_browser_command()
  if len(l:cmd) == 0
    redraw
    echohl WarningMsg
    echo "It seems that you don't have general web browser. Open URL below."
    echohl None
    echo a:url
    return
  endif
  if l:cmd =~? '^!'
    let l:cmd = substitute(l:cmd, '%URL%', '\=shellescape(a:url)', 'g')
    silent! exec l:cmd
  elseif l:cmd =~# '^:[A-Z]'
    let l:cmd = substitute(l:cmd, '%URL%', '\=a:url', 'g')
    exec l:cmd
  else
    let l:cmd = substitute(l:cmd, '%URL%', '\=shellescape(a:url)', 'g')
    call system(l:cmd)
  endif
endf

" DecodeJSON decodes a string of json into a viml object
fun! elm#util#DecodeJSON(s) abort
  let l:true = 1
  let l:false = 0
  let l:null = 0
  return eval(a:s)
endf

" Remove ANSI escape characters used for highlighting purposes
fun! s:strip_color(msg) abort
  return substitute(a:msg, '\e\[[0-9;]\+[mK]', '', 'g')
endf

" Print functions
fun! elm#util#Echo(title, msg) abort
  redraws! | echon a:title . ' ' | echohl Identifier | echon s:strip_color(a:msg) | echohl None
endf

fun! elm#util#EchoSuccess(title, msg) abort
  redraws! | echon a:title . ' ' | echohl Function | echon s:strip_color(a:msg) | echohl None
endf

fun! elm#util#EchoWarning(title, msg) abort
  redraws! | echon a:title . ' ' | echohl WarningMsg | echon s:strip_color(a:msg) | echohl None
endf

fun! elm#util#EchoError(title, msg) abort
  redraws! | echon a:title . ' ' | echohl ErrorMsg | echon s:strip_color(a:msg) | echohl None
endf

fun! elm#util#EchoLater(func_name, title, msg) abort
  let s:echo_func_name = a:func_name
  let s:echo_title = a:title
  let s:echo_msg = a:msg
endf

fun! elm#util#EchoStored() abort
  if exists('s:echo_func_name') && exists('s:echo_title') && exists('s:echo_msg')
    call elm#util#{s:echo_func_name}(s:echo_title, s:echo_msg)
    unlet s:echo_func_name
    unlet s:echo_title
    unlet s:echo_msg
  endif
endf

