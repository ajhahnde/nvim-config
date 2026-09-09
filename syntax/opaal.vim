" Vim syntax file
" Language: OPAAL

if exists("b:current_syntax")
  finish
endif

syntax case match

" Reserved words from the OPAAL 1.0 language contract.
syntax keyword opaalKeyword action break catch continue def else enum export for
syntax keyword opaalKeyword if import in let match mut return task throw try type unset while
syntax keyword opaalBoolean true false
syntax keyword opaalNull null

" Closed built-in type and generic-constraint namespaces used by annotations.
syntax keyword opaalType Any Null Bool Int Float String Bytes Path Duration ByteSize
syntax keyword opaalType List Record Table Range Status Error Function Closure
syntax keyword opaalConstraint Equal Ordered

" The core command namespace.
syntax keyword opaalBuiltin cd pwd which command exit check decode from encode to
syntax keyword opaalBuiltin first last collect length lines each where select get
syntax keyword opaalBuiltin update sort ls open save jobs fg bg wait kill help

syntax match opaalNumber "\<\d\+\%([.]\d\+\)\?\>"

" Comments start only where a new token can begin. Documentation comments are
" kept separate so themes can render them like documentation rather than notes.
syntax match opaalComment "\%(^\|\s\)\zs#.*$" contains=opaalTodo,@Spell
syntax match opaalDocComment "^\s*##\%($\|\s.*$\)" contains=opaalTodo,@Spell
syntax keyword opaalTodo TODO FIXME XXX NOTE contained

" Single quotes are exact text. Double quotes allow escapes and expansion.
syntax region opaalSingleString start=+'+ end=+'+ oneline
syntax match opaalEscape +\\\%(\\\|"\|\$\|[nrt0]\|u{[0-9A-Fa-f]\+}\)+ contained
syntax match opaalVariable "\$[A-Za-z_][A-Za-z0-9_]*" containedin=ALLBUT,opaalSingleString,opaalComment,opaalDocComment
syntax match opaalExpansion "\${" containedin=ALLBUT,opaalSingleString,opaalComment,opaalDocComment
syntax match opaalCommandSubstitution "\$(" containedin=ALLBUT,opaalSingleString,opaalComment,opaalDocComment
syntax region opaalDoubleString start=+"+ skip=+\\.+ end=+"+ oneline contains=opaalEscape,opaalVariable,opaalExpansion,opaalCommandSubstitution

" Operators and structural delimiters from the lexer contract.
syntax match opaalOperator "\%(\.\.\.\|\.\.=\||&\|&&\|||\|>>\|>&\|==\|!=\|<=\|>=\|->\|=>\|\.\.\|[;|&=<>+*/%!,.:^-]\)"
syntax match opaalDelimiter "[(){}\[\]]"

highlight default link opaalKeyword Keyword
highlight default link opaalBoolean Boolean
highlight default link opaalNull Constant
highlight default link opaalType Type
highlight default link opaalConstraint Type
highlight default link opaalBuiltin Function
highlight default link opaalNumber Number
highlight default link opaalComment Comment
highlight default link opaalDocComment SpecialComment
highlight default link opaalTodo Todo
highlight default link opaalSingleString String
highlight default link opaalDoubleString String
highlight default link opaalEscape SpecialChar
highlight default link opaalVariable Identifier
highlight default link opaalExpansion Special
highlight default link opaalCommandSubstitution Special
highlight default link opaalOperator Operator
highlight default link opaalDelimiter Delimiter

let b:current_syntax = "opaal"
