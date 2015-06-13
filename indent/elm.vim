" indentation for Elm (http://elm-lang.org/)

if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

setlocal indentexpr=GetElmIndent()
setlocal indentkeys=!^F,o,O,0|

function! GetElmIndent()
	let l:prevline = getline(v:lnum - 1)
  let l:line = getline(v:lnum)
	
  if l:prevline =~ '^\s*--'
    return match(l:prevline, '\S')
  endif

  if l:prevline =~ '^\s*$'
      return 0
  endif

  if l:prevline =~ '\C\<case\>\s\+.\+\<of\>\s*$'
    return match(l:prevline, '\C\<case\>') + &shiftwidth
  endif

  if l:prevline =~ '\C\(=\|[{([]\)\s*$'
    return match(l:prevline, '\S') + &shiftwidth
  endif

  if l:prevline =~ '\C^\s*\<type\>\s\+[^=]\+\s\+=\s\+\S\+.*$'
    if l:line =~ '^\s*|'
      return match(l:prevline, '=')
    endif
  endif

  return match(prevline, '\S')
endfunction
