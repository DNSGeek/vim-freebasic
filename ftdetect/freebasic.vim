" Vim filetype detection
" Language: FreeBASIC
"
" .bas is shared with every other BASIC dialect. If you also have plugins for
" MMBasic or MachiKania, whichever ftdetect loads first wins, because
" :setfiletype does not overwrite a filetype that is already set. To make the
" choice explicit rather than load-order dependent, set
"
"     let g:freebasic_claim_bas = 1
"
" in your vimrc. It is off by default: .fb and .bi are unambiguous, .bas is
" not.

augroup freebasic
  autocmd!
  autocmd BufNewFile,BufRead *.fb  setfiletype freebasic
  autocmd BufNewFile,BufRead *.bi  setfiletype freebasic

  if get(g:, 'freebasic_claim_bas', 0)
    autocmd BufNewFile,BufRead *.bas setfiletype freebasic
  endif
augroup END
