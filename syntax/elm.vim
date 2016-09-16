" syntax highlighting for Elm (http://elm-lang.org/)

if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword elmConditional case else if of then
syn keyword elmAlias alias
syn keyword elmTypedef type port let in
syn keyword elmImport exposing as import module where

" Operators
syn match elmOperator "\([-!#$%`&\*\+./<=>\?@\\^|~:]\|\<_\>\)"

" Types
syn match elmType "\<[A-Z][0-9A-Za-z_'-]*"
syn keyword elmNumberType number

" Delimiters
syn match elmDelimiter  "[,;]"
syn match elmBraces  "[()[\]{}]"

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
syn match elmInt "\(\<\d\+\>\)"
syn match elmFloat "\(\<\d\+\.\d\+\>\)"

" Identifiers
syn match elmTopLevelDecl "^\s*[a-zA-Z][a-zA-z0-9_]*\('\)*\s\+:\s\+" contains=elmOperator

hi def link elmTopLevelDecl Function
hi def link elmTupleFunction Normal
hi def link elmTodo Todo
hi def link elmComment Comment
hi def link elmLineComment Comment
hi def link elmString String
hi def link elmTripleString String
hi def link elmChar String
hi def link elmStringEscape Special
hi def link elmInt Number
hi def link elmFloat Float
hi def link elmDelimiter Delimiter

if get(g:, "elm_classic_highlighting", 1)
	hi def link elmTypedef Keyword
	hi def link elmImport Keyword
	hi def link elmConditional Keyword
	hi def link elmAlias Keyword
	hi def link elmOperator Operator
	hi def link elmType Type
	hi def link elmNumberType Type
	hi def link elmDelimiter Delimiter
else
	hi def link elmTypedef TypeDef
	hi def link elmImport Include
	hi def link elmConditional Conditional
	hi def link elmAlias StorageClass
	hi def link elmOperator Character
	hi def link elmType Identifier
	hi def link elmNumberType Identifier
	hi def link elmBraces Delimiter
endif

let b:current_syntax = "elm"
