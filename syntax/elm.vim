" syntax highlighting for Elm (http://elm-lang.org/)

if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword elmKeyword alias as case else exposing if import in let module of port then type where

" Operators
syn match elmOperator "\([-!#$%&\*\+./<=>\?@\\^|~:]\|\<_\>\)"
syn match elmBacktick "`[A-Za-z][A-Za-z0-9_]*\('\)*`"

" Types
syn match elmType "\<[A-Z][0-9A-Za-z_'-]*"

" Delimiters
syn match elmDelimiter  "[(),;[\]{}]"

" Functions
syn match elmTupleFunction "\((,\+)\)"

" Comments
syn keyword elmTodo TODO FIXME XXX contained
syn match elmLineComment "--.*" contains=elmTodo,@spell
syn region elmComment matchgroup=elmComment start="{-|\=" end="-}" contains=elmTodo,elmComment,@spell

" Strings
syn match elmStringEscape "\\u[0-9a-fA-F]\{4}" contained
syn match elmStringEscape "\\[nrfvbt\\\"]" contained
syn region elmString start="\"" skip="\\\"" end="\"" contains=elmStringEscape
syn region elmTripleString start="\"\"\"" skip="\\\"" end="\"\"\"" contains=elmStringEscape
syn match elmChar "'[^'\\]'\|'\\.'\|'\\u[0-9a-fA-F]\{4}'"

" Numbers
syn keyword elmNumberType number
syn match elmInt "\(\<\d\+\>\)"
syn match elmFloat "\(\<\d\+\.\d\+\>\)"

" Identifiers
syn match elmIdentifier "^\s*[a-zA-Z][a-zA-z0-9_]*\('\)*" contained
syn match elmTopLevelDecl "^\s*[a-zA-Z][a-zA-z0-9_]*\('\)*\s\+:\s\+" contains=elmIdentifier,elmOperator

hi def link elmIdentifier Identifier
hi def link elmKeyword Keyword
hi def link elmOperator Operator
hi def link elmBacktick Operator
hi def link elmTupleFunction Normal
hi def link elmType Type
hi def link elmTodo Todo
hi def link elmLineComment Comment
hi def link elmComment Comment
hi def link elmString String
hi def link elmTripleString String
hi def link elmChar String
hi def link elmStringEscape Special
hi def link elmNumberType Type
hi def link elmInt Number
hi def link elmFloat Number
hi def link elmDelimiter Delimiter

let b:current_syntax = "elm"
