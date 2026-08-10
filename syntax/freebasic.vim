" Vim syntax file
" Language:     FreeBASIC
" Maintainer:   Thomas Knox
" Last Change:  2026 Aug 09
"
" Generated:    by scripts/generateFreebasicSyntax.js - do not edit by hand
" Source:      FreeBASIC Manual (wiki export, 2023-12-24), 502 keywords
" Vocabulary is taken from the manual KeyPg pages and grouped by its own
" CatPg category pages, so no invented keywords can appear here.

if exists("b:current_syntax")
  finish
endif

syn case ignore

" FreeBASIC keeps the QB type suffixes ($ % ! # &) on the classic string
" functions, so LEFT$ and MID$ must be single syntax words. 'syn iskeyword'
" scopes this to syntax matching, leaving 'w' motions and the user's own
" 'iskeyword' alone.
if has('patch-7.4.1142')
  syn iskeyword @,48-57,_,36
else
  setlocal iskeyword+=36
endif

" ---------------------------------------------------------------- comments
" FreeBASIC has three comment forms: ' to end of line, REM to end of line,
" and the /' ... '/ block comment, which nests.
syn keyword freebasicTodo contained TODO FIXME XXX NOTE HACK

syn match  freebasicComment "'.*$" contains=freebasicTodo
syn match  freebasicComment "\<rem\>.*$" contains=freebasicTodo
syn region freebasicComment start="/'" end="'/" contains=freebasicTodo,freebasicComment

" ---------------------------------------------------------------- strings
" A quote inside a string is written "" unless -lang allows escapes, in which
" case a leading ! enables backslash escapes.
syn match  freebasicSpecial contained +\\\%(\x\+\|&h\x\+\|[0-7]\+\|[abefnrtv\\"'?]\)+
syn region freebasicString start=+!\="+ skip=+""+ end=+"+ oneline
  \ contains=freebasicSpecial,freebasicTodo

" ---------------------------------------------------------------- numbers
" Radix prefixes, with an error variant for out-of-range digits. The error
" rules are defined after the valid ones so they win at the same position.
syn match freebasicHex     "&[hH]\x\+\%(u\|l\|ul\|ll\|ull\)\=\>"
syn match freebasicOctal   "&[oO][0-7]\+\%(u\|l\|ul\|ll\|ull\)\=\>"
syn match freebasicBinary  "&[bB][01]\+\%(u\|l\|ul\|ll\|ull\)\=\>"
syn match freebasicNumberError "&[hH]\x*[g-zG-Z]\+"
syn match freebasicNumberError "&[oO][0-7]*[89a-zA-Z]\+"
syn match freebasicNumberError "&[bB][01]*[2-9a-zA-Z]\+"

syn match freebasicInteger "\<\d\+\%(u\|l\|ul\|ll\|ull\)\=\>"
syn match freebasicFloat   "\<\d\+\.\d*\%([eEdD][-+]\=\d\+\)\=[fFdD]\="
syn match freebasicFloat   "\.\d\+\%([eEdD][-+]\=\d\+\)\=[fFdD]\=\>"
syn match freebasicFloat   "\<\d\+[eEdD][-+]\=\d\+[fFdD]\=\>"

" A file number as used by OPEN, PRINT #, GET # and friends.
syn match freebasicFilenumber "#\d\+"

" ----------------------------------------------------------- preprocessor
" '\<' asserts a boundary before a word character, so it can never precede
" '#' or '$'. These rules anchor on optional leading whitespace instead.
syn match freebasicInclude "^\s*#\s*\%(include\|inclib\)\>"
syn match freebasicInclude "^\s*\$\s*\%(include\|inclib\|lang\)\>"

syn match freebasicPreProcessor "^\s*#\s*\%(define\|undef\|macro\|endmacro\)\>"
syn match freebasicPreProcessor "^\s*#\s*\%(if\|ifdef\|ifndef\|elseif\|else\|endif\)\>"
syn match freebasicPreProcessor "^\s*#\s*\%(error\|print\|assert\)\>"
syn match freebasicPreProcessor "^\s*#\s*\%(lang\|libpath\|pragma\|cmdline\)\>"
syn match freebasicPreProcessor "^\s*#\s*\%(dynamic\|static\|once\)\>"


" conditional
syn keyword freebasicConditional CASE ELSE ELSEIF IF IIF SELECT THEN WITH

" loops
syn keyword freebasicLoops CONTINUE DO FOR LOOP NEXT STEP UNTIL WEND WHILE

" control flow
syn keyword freebasicProgramFlow EXIT GOSUB GOTO RETURN SLEEP

" error handling
syn keyword freebasicErrorHandling ASSERT ASSERTWARN ERFN ERL ERMN ERR LOCAL RESUME

" debugging
syn keyword freebasicDebug STOP

" data types
syn keyword freebasicDataTypes ALIAS BOOLEAN BYTE CONST CONSTRUCTOR DECLARE DEFINED DESTRUCTOR
syn keyword freebasicDataTypes DIM DOUBLE END ENUM FBARRAY FIELD FUNCTION INTEGER LONG LONGINT
syn keyword freebasicDataTypes POINT POINTER PRIVATE PUBLIC SCOPE SHARED SHORT SINGLE STATIC SUB
syn keyword freebasicDataTypes TYPE UBYTE UINTEGER ULONG ULONGINT UNION UNSIGNED USHORT VAR
syn keyword freebasicDataTypes WSTRING ZSTRING

" type conversion
syn keyword freebasicTypeCasting CBOOL CBYTE CDBL CINT CLNG CLNGINT CSHORT CSIGN CSNG CUBYTE CUINT
syn keyword freebasicTypeCasting CULNG CULNGINT CUNSG CUSHORT STR STRING VAL VALINT VALLNG VALUINT
syn keyword freebasicTypeCasting VALULNG WSTR

" boolean literals
syn keyword freebasicBoolean FALSE TRUE

" procedures
syn keyword freebasicFunctions ANY BYREF BYVAL CALL CDECL CVA_ARG CVA_COPY CVA_END CVA_LIST
syn keyword freebasicFunctions CVA_START EXPORT LIB NAKED OVERLOAD PASCAL STDCALL VA_ARG VA_FIRST
syn keyword freebasicFunctions VA_NEXT __FASTCALL __THISCALL

" object model
syn keyword freebasicOOP ABSTRACT BASE CLASS EVENT EXTENDS IMPLEMENTS NAMESPACE OBJECT
syn keyword freebasicOOP OPERATOR OVERRIDE PROPERTY PROTECTED THIS VIRTUAL

" arrays
syn keyword freebasicArrays ARRAYLEN ARRAYSIZE ERASE LBOUND PRESERVE REDIM UBOUND

" modules and linkage
syn keyword freebasicModularizing COMMON DYLIBFREE DYLIBLOAD DYLIBSYMBOL EXTERN IMPORT

" compiler switches
syn keyword freebasicCompilerSwitches DEFBYTE DEFDBL DEFINT DEFLNG DEFLONGINT DEFSHORT DEFSNG DEFSTR
syn keyword freebasicCompilerSwitches DEFUBYTE DEFUINT DEFULONGINT DEFUSHORT ESCAPE EXPLICIT NOGOSUB
syn keyword freebasicCompilerSwitches NOKEYWORD OPTION

" operators
syn keyword freebasicLogical AND CAST CPTR IS OR XOR

" statements
syn keyword freebasicMisc ASM DATA LET OFFSETOF READ RESTORE SIZEOF SWAP TO TYPEOF USING

" console
syn keyword freebasicConsole BEEP CLS COLOR CSRLIN LOCATE OUTPUT POS SCREEN SPC TAB VIEW WIDTH
syn keyword freebasicConsole WRITE

" file i/o
syn keyword freebasicFiles APPEND BINARY CLOSE COM CONS ENCODING EOF FREEFILE INPUT LOC LOCK
syn keyword freebasicFiles LOF OPEN PIPE PUT RESET SCRN SEEK UNLOCK WINPUT

" user input
syn keyword freebasicUserInput GETJOYSTICK GETKEY GETMOUSE INKEY MULTIKEY SETMOUSE

" string functions
syn keyword freebasicString ASC BIN CHR CVD CVI CVL CVLONGINT CVS CVSHORT FORMAT HEX INSTR
syn keyword freebasicString INSTRREV LCASE LEFT LEN LSET LTRIM MID MKD MKI MKL MKLONGINT MKS
syn keyword freebasicString MKSHORT OCT RIGHT RSET RTRIM SPACE TRIM UCASE WBIN WCHR WHEX WOCT
syn keyword freebasicString WSPACE

" maths
syn keyword freebasicMath ABS ACOS ASIN ATAN2 ATN COS EXP FIX FRAC INT LOG RANDOM RANDOMIZE
syn keyword freebasicMath RND SGN SIN SQR TAN

" memory
syn keyword freebasicMemory ALLOCATE CALLOCATE CLEAR DEALLOCATE FB_MEMCOPY FB_MEMCOPYCLEAR
syn keyword freebasicMemory FB_MEMMOVE PEEK POKE REALLOCATE

" pointers
syn keyword freebasicPointer SADD

" bit manipulation
syn keyword freebasicBitManipulation ACCESS BIT BITRESET BITSET HIBYTE HIWORD LOBYTE LOWORD

" date and time
syn keyword freebasicDateTime DATE DATEADD DATEDIFF DATEPART DATESERIAL DATEVALUE DAY GET HOUR
syn keyword freebasicDateTime ISDATE MINUTE MONTH MONTHNAME NOW SECOND SETDATE SETTIME TIMER
syn keyword freebasicDateTime TIMESERIAL TIMEVALUE WEEKDAY WEEKDAYNAME YEAR

" graphics
syn keyword freebasicGraphics ADD ALPHA BLOAD BSAVE CIRCLE CUSTOM DRAW FLIP IMAGECONVERTROW
syn keyword freebasicGraphics IMAGECREATE IMAGEDESTROY IMAGEINFO PAINT PALETTE PCOPY PMAP
syn keyword freebasicGraphics POINTCOORD PRESET PSET RGB RGBA SCREENCONTROL SCREENCOPY
syn keyword freebasicGraphics SCREENEVENT SCREENGLPROC SCREENINFO SCREENLIST SCREENLOCK
syn keyword freebasicGraphics SCREENPTR SCREENRES SCREENSET SCREENSYNC SCREENUNLOCK TRANS WINDOW
syn keyword freebasicGraphics WINDOWTITLE

" hardware
syn keyword freebasicHardware INP LPOS LPRINT LPT OUT STICK STRIG WAIT

" threading
syn keyword freebasicMultithreading CONDBROADCAST CONDCREATE CONDDESTROY CONDSIGNAL CONDWAIT
syn keyword freebasicMultithreading MUTEXCREATE MUTEXDESTROY MUTEXLOCK MUTEXUNLOCK THREADCALL
syn keyword freebasicMultithreading THREADCREATE THREADDETACH THREADSELF THREADWAIT

" operating system
syn keyword freebasicShell CHAIN CHDIR CURDIR DIR ENVIRON EXEC EXEPATH FILEATTR FILECOPY
syn keyword freebasicShell FILEDATETIME FILEEXISTS FILEFLUSH FILELEN FILESETEOF FRE
syn keyword freebasicShell ISREDIRECTED KILL MKDIR NAME RMDIR RUN SETENVIRON SHELL

" preprocessor
syn keyword freebasicPreProcessor DYNAMIC ERROR LINE PRINT TIME

" predefined symbols
syn keyword freebasicPredefined AS COMMAND SYSTEM __DATE_ISO__ __DATE__ __FB_64BIT__ __FB_ARGC__
syn keyword freebasicPredefined __FB_ARGV__ __FB_ARG_COUNT__ __FB_ARG_EXTRACT__ __FB_ARG_LEFTOF__
syn keyword freebasicPredefined __FB_ARG_RIGHTOF__ __FB_ARM__ __FB_ASM__ __FB_BACKEND__
syn keyword freebasicPredefined __FB_BIGENDIAN__ __FB_BUILD_DATE_ISO__ __FB_BUILD_DATE__
syn keyword freebasicPredefined __FB_BUILD_SHA1__ __FB_CYGWIN__ __FB_DARWIN__ __FB_DEBUG__
syn keyword freebasicPredefined __FB_DOS__ __FB_ERR__ __FB_EVAL__ __FB_FPMODE__ __FB_FPU__
syn keyword freebasicPredefined __FB_FREEBSD__ __FB_GCC__ __FB_GUI__ __FB_IIF__ __FB_JOIN__
syn keyword freebasicPredefined __FB_LANG__ __FB_LINUX__ __FB_MAIN__ __FB_MIN_VERSION__ __FB_MT__
syn keyword freebasicPredefined __FB_NETBSD__ __FB_OPENBSD__ __FB_OPTIMIZE__ __FB_OPTION_BYVAL__
syn keyword freebasicPredefined __FB_OPTION_DYNAMIC__ __FB_OPTION_ESCAPE__ __FB_OPTION_EXPLICIT__
syn keyword freebasicPredefined __FB_OPTION_GOSUB__ __FB_OPTION_PRIVATE__ __FB_OUT_DLL__
syn keyword freebasicPredefined __FB_OUT_EXE__ __FB_OUT_LIB__ __FB_OUT_OBJ__ __FB_PCOS__
syn keyword freebasicPredefined __FB_PPC__ __FB_QUERY_SYMBOL__ __FB_QUOTE__ __FB_SIGNATURE__
syn keyword freebasicPredefined __FB_SSE__ __FB_UNIQUEID_POP__ __FB_UNIQUEID_PUSH__
syn keyword freebasicPredefined __FB_UNIQUEID__ __FB_UNIX__ __FB_UNQUOTE__ __FB_VECTORIZE__
syn keyword freebasicPredefined __FB_VERSION__ __FB_VER_MAJOR__ __FB_VER_MINOR__ __FB_VER_PATCH__
syn keyword freebasicPredefined __FB_WIN32__ __FB_X86__ __FB_XBOX__ __FILE_NQ__ __FILE__
syn keyword freebasicPredefined __FUNCTION_NQ__ __FUNCTION__ __LINE__ __PATH__ __TIME__

" QB $-suffixed spellings (-lang qb / fblite)
syn keyword freebasicQBSuffix BIN$ CHR$ COMMAND$ DATE$ ENVIRON$ HEX$ INKEY$ INPUT$ LCASE$ LEFT$
syn keyword freebasicQBSuffix LTRIM$ MID$ MKD$ MKI$ MKL$ MKLONGINT$ MKS$ MKSHORT$ OCT$ RIGHT$
syn keyword freebasicQBSuffix RTRIM$ SPACE$ STR$ STRING$ TIME$ TRIM$ UCASE$

" ------------------------------------------------------------- operators
syn match freebasicOperator "[-+*/\\\\^<>=&]"
syn match freebasicOperator "[<>]="
syn match freebasicOperator "<>"
syn match freebasicOperator "\\%(+\\|-\\|\\*\\|/\\|\\\\\\|\\^\\|&\\)="

" ------------------------------------------------------------------ labels
" A label is a bare identifier followed by a colon at the start of a line,
" or a line number. The previous pattern was "\<^\w+:\>", which cannot match:
" \< before ^ is meaningless and \w+ is a word character then a literal plus.
syn match freebasicLabel      "^\s*\w\+\s*:\%([^=]\|$\)\@="
syn match freebasicLineNumber "^\s*\d\+\>"

" ------------------------------------------------------------------- sync
" Block comments and long procedures need more than a screenful of context.
syn sync minlines=100

" -------------------------------------------------------------- highlight
hi def link freebasicArrays           StorageClass
hi def link freebasicBitManipulation  Operator
hi def link freebasicBoolean          Boolean
hi def link freebasicComment          Comment
hi def link freebasicCompilerSwitches PreCondit
hi def link freebasicConditional      Conditional
hi def link freebasicConsole          Special
hi def link freebasicDataTypes        Type
hi def link freebasicDateTime         Function
hi def link freebasicDebug            Special
hi def link freebasicErrorHandling    Exception
hi def link freebasicFilenumber       Number
hi def link freebasicFiles            Special
hi def link freebasicFloat            Float
hi def link freebasicFunctions        Function
hi def link freebasicGraphics         Function
hi def link freebasicHardware         Special
hi def link freebasicHex              Number
hi def link freebasicOctal            Number
hi def link freebasicBinary           Number
hi def link freebasicInclude          Include
hi def link freebasicInteger          Number
hi def link freebasicLabel            Label
hi def link freebasicLineNumber       Label
hi def link freebasicLogical          Operator
hi def link freebasicLoops            Repeat
hi def link freebasicMath             Function
hi def link freebasicMemory           Function
hi def link freebasicMisc             Statement
hi def link freebasicModularizing     Special
hi def link freebasicMultithreading   Special
hi def link freebasicNumberError      Error
hi def link freebasicOOP              StorageClass
hi def link freebasicOperator         Operator
hi def link freebasicPointer          Special
hi def link freebasicPredefined       PreProc
hi def link freebasicPreProcessor     PreProc
" freebasicKeyword catches any keyword the manual adds that no category
" page claims. Currently empty; the generator reports it when it fills.
hi def link freebasicKeyword          Keyword
" The $ spellings are only correct in -lang qb and fblite. Link this to
" WarningMsg if you compile with -lang fb and want them flagged.
hi def link freebasicQBSuffix         String
hi def link freebasicProgramFlow      Statement
hi def link freebasicShell            Special
hi def link freebasicSpecial          SpecialChar
hi def link freebasicString           String
hi def link freebasicTodo             Todo
hi def link freebasicTypeCasting      Type
hi def link freebasicUserInput        Statement

" b:current_syntax must be set LAST. The previous version set it on line 9,
" before defining any rules, which defeats the guard at the top of the file
" and breaks ':syn include' of this file from another syntax script.
let b:current_syntax = "freebasic"
