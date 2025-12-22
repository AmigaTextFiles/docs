G4C

winbig 0 11 632 216 "Gui4Cli Help System"
winsmall 0 -1 150 21
wintype 11110001
varpath "fastread.gc"

xonopen
ifexists window fastread.gc
    ;Nop
else
    setgad viewtext.g 3 off
    setgad viewtext.g 4 off
    setgad viewtext.g 5 off
endif

xonclose
set translation on
lvuse viewtext.g 1
lvclear
ifexists window fastread.gc
    gosub fastread.gc exit
endif

xonrmb
set translation on
lvuse viewtext.g 1
lvclear
ifexists window fastread.gc
    update viewtext.g 2 ""
    guiwindow fastread.gc front
    guiwindow fastread.gc on
else
    guiclose viewtext.g
endif

box 0 0 372 12 out button

xlistview 0 12 0 211 "" "" "" 20 num
gadid  1
gadfont topaz.font 8 000

text 10 0 372 12 "" 50 nobox
gadid 2

xbutton 372 0 60 12 Macro
gadid 3
if $VTMACRO > ""
andifexists file $VTMACRO
    run 'newshell "con:90/50/450/150/OUTPUT/CLOSE WAIT" from $VTMACRO'
else
    reqfile -1 -1 200 -60 "Run Macro..." load macro GCHELP:
    if $macro != ""
        run 'newshell "con:90/50/450/150/OUTPUT/CLOSE WAIT" from $macro'
        macro = ""
    endif
endif

xbutton 432 0 50 12 Prev
gadid 4
lvuse fastread.gc 1
if $$lv.line != 0
    setgad viewtext.g 4 on
    setgad viewtext.g 5 on
    lvgo prev
    topic = $$lv.rec
    gosub viewtext.g switchgads
    gosub fastread.gc fetchtext
endif

xbutton 482 0 50 12 Next
gadid 5
lvuse fastread.gc 1
if $$lv.line != $total
    setgad viewtext.g 4 on
    setgad viewtext.g 5 on
    lvgo next
    topic = $$lv.rec
    gosub viewtext.g switchgads
    gosub fastread.gc fetchtext
endif

xbutton 532 0 50 12 Grab
gosub viewtext.g grabtext

xbutton 582 0 50 12 Quit
guiclose viewtext.g

xroutine switchgads
lvuse fastread.gc 1
total = $$lv.total
counter total dec 1
if $$lv.line = 0
    setgad viewtext.g 4 off
    setgad viewtext.g 5 on
    return
elseif $$lv.line = $total
    setgad viewtext.g 4 on
    setgad viewtext.g 5 off
    return
else
    setgad viewtext.g 4 on
    setgad viewtext.g 5 on
    return
endif

xroutine grabtext
reqfile -1 -1 200 -60 "Save Text As.." save txt SYS:
if $txt != ""
    lvuse viewtext.g 1
    lvsave $txt
endif
