" Vim indent file
" Language:   FreeBASIC
" Maintainer: Thomas Knox

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetFreeBasicIndent()
setlocal indentkeys=0=~end,0=~else,0=~elseif,0=~next,0=~loop,0=~wend,0=~case,0=~#endif,0=~#else,!^F,o,O
setlocal nolisp
setlocal nosmartindent

let b:undo_indent = "setlocal indentexpr< indentkeys< lisp< smartindent<"

if exists("*GetFreeBasicIndent")
  finish
endif

" Removes strings and trailing comments so a keyword inside either does not
" drive the indent. Without this, PRINT "next up" reads as a NEXT.
function! s:Code(line) abort
  let l:text = substitute(a:line, '"\%(""\|[^"]\)*"', '""', 'g')
  let l:text = substitute(l:text, "'.*$", '', '')
  let l:text = substitute(l:text, '\c\<REM\>.*$', '', '')
  return l:text
endfunction

" A single line IF needs no indent because it has no END IF. It is a block
" opener only when THEN is the last thing on the line.
function! s:IsBlockIf(code) abort
  if a:code !~? '^\s*IF\>'
    return 0
  endif
  return a:code =~? '\<THEN\>\s*$'
endfunction

function! GetFreeBasicIndent() abort
  let l:prevnum = prevnonblank(v:lnum - 1)

  if l:prevnum == 0
    return 0
  endif

  let l:prev = s:Code(getline(l:prevnum))
  let l:this = s:Code(getline(v:lnum))
  let l:ind = indent(l:prevnum)
  let l:sw = shiftwidth()

  " Preprocessor conditionals keep their own column so they stay readable
  " against the surrounding code.
  if l:this =~? '^\s*#'
    return 0
  endif

  if l:prev =~? '^\s*#'
    let l:ind = indent(prevnonblank(l:prevnum - 1))
  endif

  " -------------------------------------------------------------- openers
  if s:IsBlockIf(l:prev)
    let l:ind += l:sw
  endif

  if l:prev =~? '^\s*\%(ELSE\|ELSEIF\)\>'
    let l:ind += l:sw
  endif

  " FOR only opens a block at the start of a statement. It also appears in
  " OPEN ... FOR INPUT, which must not indent anything.
  if l:prev =~? '^\s*FOR\>'
    let l:ind += l:sw
  endif

  " DO WHILE is a single opener. Match DO first so a bare WHILE that belongs
  " to it is not counted twice.
  if l:prev =~? '^\s*DO\>'
    let l:ind += l:sw
  elseif l:prev =~? '^\s*WHILE\>'
    let l:ind += l:sw
  endif

  " A declaration is not a block. DECLARE SUB Foo() opens nothing, and a
  " one-line TYPE alias such as TYPE Handle AS INTEGER has no END TYPE.
  if l:prev =~? '^\s*\%(SUB\|FUNCTION\|PROPERTY\|OPERATOR\|CONSTRUCTOR\|DESTRUCTOR\)\>'
    \ && l:prev !~? '^\s*DECLARE\>'
    let l:ind += l:sw
  endif

  if l:prev =~? '^\s*\%(TYPE\|ENUM\|UNION\)\>' && l:prev !~? '\<AS\>'
    let l:ind += l:sw
  endif

  if l:prev =~? '^\s*\%(NAMESPACE\|SCOPE\|WITH\|EXTERN\s\+"\)\>\='
    \ && l:prev =~? '^\s*\%(NAMESPACE\|SCOPE\|WITH\)\>'
    let l:ind += l:sw
  endif

  " SELECT CASE indents once, then each CASE indents its own body.
  if l:prev =~? '^\s*SELECT\s\+CASE\>'
    let l:ind += l:sw
  endif

  if l:prev =~? '^\s*CASE\>'
    let l:ind += l:sw
  endif

  " -------------------------------------------------------------- closers
  if l:this =~? '^\s*\%(NEXT\|LOOP\|WEND\)\>'
    let l:ind -= l:sw
  endif

  if l:this =~? '^\s*END\s\+\%(IF\|SUB\|FUNCTION\|PROPERTY\|OPERATOR\|CONSTRUCTOR\|DESTRUCTOR\|TYPE\|ENUM\|UNION\|NAMESPACE\|SCOPE\|WITH\|EXTERN\)\>'
    let l:ind -= l:sw
  endif

  if l:this =~? '^\s*\%(ELSE\|ELSEIF\)\>'
    let l:ind -= l:sw
  endif

  " A CASE closes the previous CASE body; END SELECT closes the last CASE
  " and the SELECT itself.
  if l:this =~? '^\s*CASE\>'
    let l:ind -= l:sw
  endif

  if l:this =~? '^\s*END\s\+SELECT\>'
    let l:ind -= (2 * l:sw)
  endif

  return l:ind < 0 ? 0 : l:ind
endfunction
