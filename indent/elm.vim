" indentation for Elm (http://elm-lang.org/)

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal expandtab
setlocal shiftwidth=4
setlocal indentexpr=GetElmIndent()
setlocal indentkeys+=0=else,0=if,0=of,0=import,0=then,0=type,0\|,0},0\],0)
setlocal nolisp
setlocal nosmartindent

" Comment formatting
setlocal comments=s1fl:{-,mb:\ ,ex:-},:--

" Only define the function once.
if exists("*GetElmIndent")
	finish
endif

" Skipping pattern, for comments
function! s:GetLineWithoutFullComment(lnum)
	let lnum = a:lnum - 1

	while synIDattr(synID(lnum, 1, 0), "name") =~? "comment" && lnum > 0
		let lnum = lnum - 1	
	endwhile

	if getline(lnum) =~ '^\s*$' && lnum > 0
		let lnum = lnum - 1
	endif

	return lnum
	
	let lnum = prevnonblank(a:lnum - 1)
	let lline = substitute(getline(lnum), '--.*$', '', '')
	while lline =~ '^\s*$' && lnum > 0
		let lnum = prevnonblank(lnum - 1)
		let lline = substitute(getline(lnum), '--.*$', '', '')
	endwhile
	return lnum
endfunction

" Indent pairs
function! s:FindPair(pstart, pmid, pend)
	"call search(a:pend, 'bW')
	return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"'))
endfunction

function! GetElmIndent()
	if synIDattr(synID(v:lnum, 1, 0), "name") =~? "comment"
		return 0
	endif

	" Find a non-commented line above the current line.
	let lnum = s:GetLineWithoutFullComment(v:lnum)

	" At the start of the file use zero indent.
	if lnum == 0
		return 0
	endif

	let ind = indent(lnum)
	"let lline = substitute(getline(lnum), '--.*$', '', '')
	let lline = getline(lnum)

	let line = getline(v:lnum)

	" Indent if current line begins with '}':
	if line =~ '^\s*}'
		return s:FindPair('{', '', '}')

	" Indent if current line begins with 'else':
	elseif line =~ '^\s*else\>'
		if lline !~ '^\s*\(if\|then\)\>'
			return s:FindPair('\<if\>', '', '\<else\>')
		endif

	" Indent if current line begins with 'then':
	elseif line =~ '^\s*then\>'
		if lline !~ '^\s*\(if\|else\)\>'
			return s:FindPair('\<if\>', '', '\<then\>')
		endif

	elseif line =~ '->' && line !~ ':' && line !~ '\\'
		return indent(search('^\s*case', 'bWn')) + &sw
	endif

	" Add a 'shiftwidth' after lines ending with:
	if lline =~ '\(|\|=\|->\|<-\|(\|\[\|{\|\<\(in\|of\|else\|if\|then\)\)\s*$'
		let ind = ind + &sw

	elseif lline =~ '^\s*type' && line =~ '^\s*='
		let ind = ind + &sw

	" Back to normal indent after lines ending with 'in':
	"elseif lline =~ '\<in\s*$' && lline !~ '^\s*in\>'
"		let ind = s:FindPair('\<let\>', '', '\<in\>')

	" Back to normal indent after lines ending with '}':
	"elseif lline =~ '}\s*$'
	"	let ind = ind - &sw
		"let ind = s:FindPair('{', '','}')

  " Back to normal indent after lines ending with ']', '|]' or '>]':
  " elseif lline =~ '\]\s*$'
  "  let ind = s:FindPair('\[', '','\]')

  " Back to normal indent after comments:
  elseif lline =~ '-}\s*$'
    call search('-}', 'bW')
    let ind = indent(searchpair('{-', '', '-}', 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))

 	" Back to normal indent after lines ending with ')':
 	elseif lline =~ ')\s*$'
   	let ind = s:FindPair('(', '',')')

 	else
   	"let i = indent(v:lnum)
   	"return i == 0 ? ind : i
 	endif

	return ind
endfunc
