" Vim syntax file
" Language: OPAAL

if exists("b:current_syntax")
  finish
endif

syntax case match
syntax sync minlines=100

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
syntax keyword opaalBuiltin cd pwd which exit check decode from encode to
syntax keyword opaalBuiltin first last collect length lines each where select get
syntax keyword opaalBuiltin update sort ls open save jobs fg bg wait kill help

syntax match opaalNumber "\<\d\+\%([.]\d\+\)\?\>"

" Comments start only where a new token can begin. Documentation comments are
" kept separate so themes can render them like documentation rather than notes.
syntax match opaalComment "\%(^\|\s\)\zs#.*$" contains=opaalTodo,@Spell
syntax match opaalDocComment "^\s*##\%($\|\s.*$\)" contains=opaalTodo,@Spell
syntax keyword opaalTodo TODO FIXME XXX NOTE contained

" Single quotes are exact text. Double quotes allow escapes and braced interpolation.
syntax region opaalSingleString start=+'+ end=+'
syntax match opaalEscape +\\\%(\\\|"\|[nrt0]\|u{[0-9A-Fa-f]\{1,6}}\)+ contained
syntax cluster opaalExpression contains=opaalKeyword,opaalBoolean,opaalNull,opaalType,opaalConstraint,opaalBuiltin,opaalNumber,opaalSingleString,opaalDoubleString,opaalOperator,opaalDelimiter,opaalBraceBlock
syntax region opaalInterpolation matchgroup=opaalInterpolationDelimiter start=+{+ end=+}+ contained contains=@opaalExpression
syntax match opaalEscapedBrace +{{\|}}+ contained
syntax region opaalDoubleString start=+"+ end=+"+ contains=opaalEscape,opaalInterpolation,opaalEscapedBrace

" Operators and structural delimiters from the lexer contract.
syntax match opaalOperator "\%(\.\.\.\|\.\.=\||&\|&&\|||\|>>\|>&\|==\|!=\|<=\|>=\|->\|=>\|\.\.\|[;|&=<>+*/%!,.:^-]\)"
syntax match opaalDelimiter "[(){}\[\]]"
syntax region opaalBraceBlock matchgroup=opaalDelimiter start=+{+ end=+}+ contained contains=@opaalExpression

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
highlight default link opaalInterpolation Identifier
highlight default link opaalInterpolationDelimiter Special
highlight default link opaalEscapedBrace SpecialChar
highlight default link opaalOperator Operator
highlight default link opaalDelimiter Delimiter

let b:current_syntax = "opaal"
