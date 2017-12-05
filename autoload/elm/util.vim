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

function! elm#util#GoToModule(name)
  if empty(a:name) | return | endif
  if empty(matchstr(a:name, '^Native\.'))
    let l:extension = '.elm'
  else
    let l:extension = '.js'
  endif

  " Strip trailing func name if it exists. So My.Module.func becomes My.Module
  " Relies on functions starting with a lower case letter
  let l:module_name = substitute(a:name, '\.[a-z][A-Za-z0-9_]\+$', '', '')
  let l:root = elm#FindRootDirectory()

  while 1

    let l:module_path = s:findModule(l:module_name, l:root, l:extension)
    if l:module_path != ""
      exec 'edit ' . fnameescape(l:module_path)
      return
    endif

    " We can't find the module name, so see if it is a module alias by looking
    " for ' as M ' where M is our token
    let l:line = search(' as ' . l:module_name . '\( \|$\)', 'nw')
    if line
      let l:contents = getline(line)

      " Convert 'import My.Module as MM ' to 'My.Module' to repeat the lookup
      let l:module_import_name = substitute(substitute(l:contents, 'import ', '', ''), ' as .*', '', '')
      let l:module_path = s:findModule(l:module_import_name, l:root, l:extension)
      if l:module_path != ""
        exec 'edit ' . fnameescape(l:module_path)
        return
      endif
    endif

    " Strip the last segment off and try again as we might be over a string
    " that is My.Module.Type as types start with capital letters and so are
    " indistinguishable from modules
    let l:new_module_name = substitute(l:module_name, '\.[^\.]*$', '', '')

    if l:module_name == l:new_module_name
      return s:error("Can't find module \"" . l:module_name . "\"")
    else
      let l:module_name = l:new_module_name
    endif
  endwhile
endfunction

function! s:findModule(module_name, root, extension)
  let l:rel_path = substitute(a:module_name, '\.', '/', 'g') . a:extension

  let l:module_file = s:findLocalModule(l:rel_path, a:root)
  if !filereadable(l:module_file)
    let l:module_file = s:findDependencyModule(l:rel_path, a:root)
  endif

  if filereadable(l:module_file)
    return l:module_file
  else
    return ""
  endif
endfunction

function! s:findLocalModule(rel_path, root)
  let l:package_json = a:root . '/elm-package.json'
  if exists('*json_decode')
    let l:package = json_decode(readfile(l:package_json))
    let l:source_roots = l:package['source-directories']
  else
    " This is a fallback for vim's which do not support json_decode.
    " It simply only looks in the 'src' subdirectory and fails otherwise.
    let l:source_roots = ['src']
  end
  for l:source_root in l:source_roots
    let l:file_path = a:root . '/' . l:source_root . '/' . a:rel_path
    if !filereadable(l:file_path)
      continue
    endif
    return l:file_path
  endfor
endfunction

function! s:findDependencyModule(rel_path, root)
  " If we are a dependency ourselves, we need to check our siblings.
  " This is because elm package doesn't install dependencies recursively.
  let l:root = substitute(a:root, '\/elm-stuff/packages.\+$', '', '')

  " We naively craws the dependencies dir for any fitting module name.
  " If it exists, we'll find it. If multiple filenames match,
  " there's a chance we return the wrong one.
  let l:module_paths = glob(l:root . '/elm-stuff/packages/**/' . a:rel_path, 0, 1)
  if len(l:module_paths) > 0
    return l:module_paths[0]
  endif
endfunction

" Using the built-in :echoerr prints a stacktrace, which isn't that nice.
" From: https://github.com/moll/vim-node/blob/master/autoload/node.vim
function! s:error(msg)
	echohl ErrorMsg
	echomsg a:msg
	echohl NONE
	let v:errmsg = a:msg
endfunction
