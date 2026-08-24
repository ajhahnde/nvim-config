" Vim syntax file
" Language: Flash (fsh)

if exists("b:current_syntax")
  finish
endif

syntax case match

" Reserved words from the Flash v1 contract.
syntax keyword flashKeyword break catch continue def else export for if import in
syntax keyword flashKeyword let match mut return throw try unset while
syntax keyword flashBoolean true false
syntax keyword flashNull null

" Closed built-in type namespace used by annotations.
syntax keyword flashType Any Null Bool Int Float String Bytes Path Duration ByteSize
syntax keyword flashType List Record Table Range Status Error Function Closure

" The exact v1 core command namespace.
syntax keyword flashBuiltin cd pwd which command exit check decode from encode to
syntax keyword flashBuiltin first last collect length lines each where select get
syntax keyword flashBuiltin update sort ls open save jobs fg bg wait kill help

syntax match flashNumber "\<\d\+\%([.]\d\+\)\?\>"

" Comments start only where a new token can begin. Documentation comments are
" kept separate so themes can render them like documentation rather than notes.
syntax match flashComment "\%(^\|\s\)\zs#.*$" contains=flashTodo,@Spell
syntax match flashDocComment "^\s*##\%($\|\s.*$\)" contains=flashTodo,@Spell
syntax keyword flashTodo TODO FIXME XXX NOTE contained

" Single quotes are exact text. Double quotes allow escapes and expansion.
syntax region flashSingleString start=+'+ end=+'+ oneline
syntax match flashEscape +\\\%(\\\|"\|\$\|[nrt0]\|u{[0-9A-Fa-f]\+}\)+ contained
syntax match flashVariable "\$[A-Za-z_][A-Za-z0-9_]*" containedin=ALLBUT,flashSingleString,flashComment,flashDocComment
syntax match flashExpansion "\${" containedin=ALLBUT,flashSingleString,flashComment,flashDocComment
syntax match flashCommandSubstitution "\$(" containedin=ALLBUT,flashSingleString,flashComment,flashDocComment
syntax region flashDoubleString start=+"+ skip=+\\.+ end=+"+ oneline contains=flashEscape,flashVariable,flashExpansion,flashCommandSubstitution

" Operators and structural delimiters from the lexer contract.
syntax match flashOperator "\%(\.\.\.\|\.\.=\||&\|&&\|||\|>>\|>&\|==\|!=\|<=\|>=\|->\|=>\|\.\.\|[;|&=<>+*/%!,.:^-]\)"
syntax match flashDelimiter "[(){}\[\]]"

highlight default link flashKeyword Keyword
highlight default link flashBoolean Boolean
highlight default link flashNull Constant
highlight default link flashType Type
highlight default link flashBuiltin Function
highlight default link flashNumber Number
highlight default link flashComment Comment
highlight default link flashDocComment SpecialComment
highlight default link flashTodo Todo
highlight default link flashSingleString String
highlight default link flashDoubleString String
highlight default link flashEscape SpecialChar
highlight default link flashVariable Identifier
highlight default link flashExpansion Special
highlight default link flashCommandSubstitution Special
highlight default link flashOperator Operator
highlight default link flashDelimiter Delimiter

let b:current_syntax = "flash"
