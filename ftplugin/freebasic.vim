" Vim filetype plugin
" Language:   FreeBASIC
" Maintainer: Thomas Knox

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" FreeBASIC has ' and REM line comments and /' '/ block comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/',mb:',ex:'/,:',:REM
setlocal commentstring='\ %s

setlocal formatoptions-=t
setlocal formatoptions+=croql

setlocal foldmethod=indent
setlocal foldlevel=99

" The QB type suffixes are part of an identifier, so * and w treat LEFT$ as
" one word. NOTE: 'ignorecase' is a global option, so it is deliberately not
" set here - doing so would change search behaviour for every other buffer.
setlocal iskeyword=@,48-57,_,$

" gf and :find follow #include "..." paths.
setlocal include=^\\s*#\\s*include
setlocal suffixesadd=.bi,.bas,.fb

if exists('loaded_matchit') && !exists('b:match_words')
  let b:match_ignorecase = 1
  let b:match_words =
    \ '\<if\>.\{-}\<then\>\s*$:\<elseif\>:\<else\>:\<end\s\+if\>,' .
    \ '\<for\>:\<next\>,' .
    \ '\<do\>:\<loop\>,' .
    \ '\<while\>:\<wend\>,' .
    \ '\<select\s\+case\>:\<case\>:\<end\s\+select\>,' .
    \ '\<sub\>:\<end\s\+sub\>,' .
    \ '\<function\>:\<end\s\+function\>,' .
    \ '\<type\>:\<end\s\+type\>,' .
    \ '\<enum\>:\<end\s\+enum\>,' .
    \ '\<union\>:\<end\s\+union\>,' .
    \ '\<namespace\>:\<end\s\+namespace\>,' .
    \ '\<scope\>:\<end\s\+scope\>,' .
    \ '\<with\>:\<end\s\+with\>,' .
    \ '^\s*#\s*if\%(def\|ndef\)\=\>:^\s*#\s*else\%(if\)\=\>:^\s*#\s*endif\>'
endif

let b:undo_ftplugin = "setlocal fo< com< cms< isk< fdm< fdl< inc< sua<"
