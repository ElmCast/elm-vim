" indentation for Elm (http://elm-lang.org/)

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

" Local defaults
setlocal expandtab
setlocal indentexpr=GetElmIndent()
setlocal indentkeys+=0=else,0=if,0=of,0=import,0=then,0=type,0\|,0},0\],0),=-},0=in
setlocal nolisp
setlocal nosmartindent

" Comment formatting
setlocal comments=s1fl:{-,mb:\ ,ex:-},:--

" Only define the function once.
if exists("*GetElmIndent")
	finish
endif

" Indent pairs
function! s:FindPair(pstart, pmid, pend)
	"call search(a:pend, 'bW')
	return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"'))
endfunction

function! GetElmIndent()
	let lnum = v:lnum - 1

	" Ident 0 if the first line of the file:
	if lnum == 0
		return 0
	endif

	let ind = indent(lnum)
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

	" HACK: Indent lines in case with nearest case clause:
	elseif line =~ '->' && line !~ ':' && line !~ '\\'
		return indent(search('^\s*case', 'bWn')) + &sw

	" HACK: Don't change the indentation if the last line is a comment.
	elseif lline =~ '^\s*--'
		return ind

	" Align the end of block comments with the start
	elseif line =~ '^\s*-}'
		return indent(search('{-', 'bWn'))

	" Indent double shift after let with an empty rhs
	elseif lline =~ '\<let\>.*\s=$'
		return ind + 4 + &sw

	" Align 'in' with the parent let.
	elseif line =~ '^\s*in\>'
		return indent(search('^\s*let', 'bWn'))

	" Align bindings with the parent let.
	elseif lline =~ '\<let\>'
		return ind + 4

	" Align bindings with the parent in.
	elseif lline =~ '^\s*in'
		return ind + 4

	endif

	" Add a 'shiftwidth' after lines ending with:
	if lline =~ '\(|\|=\|->\|<-\|(\|\[\|{\|\<\(of\|else\|if\|then\)\)\s*$'
		let ind = ind + &sw

	" Add a 'shiftwidth' after lines starting with type ending with '=':
	elseif lline =~ '^\s*type' && line =~ '^\s*='
		let ind = ind + &sw

	" Back to normal indent after comments:
	elseif lline =~ '-}\s*$'
		call search('-}', 'bW')
		let ind = indent(searchpair('{-', '', '-}', 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))

	" Ident some operators if there aren't any starting the last line.
	elseif line =~ '^\s*\(!\|&\|(\|`\|+\||\|{\|[\|,\)' && lline !~ '^\s*\(!\|&\|(\|`\|+\||\|{\|[\|,\)' && lline !~ '^\s*$'
		let ind = ind + &sw

	endif

	return ind
endfunc
