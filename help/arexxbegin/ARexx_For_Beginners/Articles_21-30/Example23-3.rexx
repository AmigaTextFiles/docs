/* Example23-3 */

Clear = 'c'x
Down = 'a'x
Bell = '7'x

OPTIONS FAILAT 21

SAY Clear'This program will display some information in this window'
SAY 'and some in ED windows.'
SAY Down'You may have to enlarge your Shell/CLI window to see the action!'

CALL PressAny

ADDRESS 'COMMAND'

SAY 'The following line:-'Down
SAY ' 'SOURCELINE(15)
SAY Down'has just been used to make AmigaDOS the current host.'
SAY 'Now this line:-'Down
SAY '  'SOURCELINE(24)
SAY Down'has been used to send the AmigaDOS command DIR to AmigaDOS'
SAY 'so that you can view the RAM: directory:-.'Down
'DIR Ram:'

CALL PressAny

SAY Down'AmigaDOS is still the current host. The following two command lines:-'Down
SAY '  'SOURCELINE(34)
SAY '  'SOURCELINE(35)

SAY Down'will now be sent to it to copy this program and your Startup-Sequence to RAM:'

'COPY Example23-3.rexx RAM:'
'COPY S:Startup-Sequence RAM:'

SAY Down'Just to make sure, now we will use this line:-'Down
SAY '  'SOURCELINE(41)
SAY Down'to re-view the RAM: directory to see that they are really there:-'Down

'DIR Ram:'

CALL PressAny

SAY Down'Now this AmigaDOS command command line:-'Down
SAY '  'SOURCELINE(49)
SAY Down'will be used to create an ED window'

'RUN >Nil: ED Dummy'

SAY Down'IMPORTANT - Click in this Shell/CLI window to make it ACTIVE!!'

CALL PressAny

ADDRESS 'Ed'

SAY Down'The following line:-'Down
SAY '  'SOURCELINE(55)
SAY Down'has just been used to make "Ed" the CURRENT host.'
SAY '"COMMAND" is now the PREVIOUS host.'
SAY Down'"Ed" will now be sent this command line:-'Down
SAY '  'SOURCELINE(67)
SAY Down'to display this program (i.e. RAM:Example23-3.rexx).'

CALL DidNotAppear

'OP "RAM:Example23-3.rexx"'

CALL PressAny

ADDRESS

SAY Down'Now this line:-'Down
SAY '  'SOURCELINE(71)
SAY Down'has just been used to swap between the previous and current hosts.'
SAY '"Ed" is now the PREVIOUS host and "COMMAND" the CURRENT host.'

SAY 'Another ED window is now opened with this command line:-'Down
SAY '  'SOURCELINE(81)

'RUN >Nil: ED Dummy2'

SAY Down'IMPORTANT - Click in this Shell/CLI window to make it ACTIVE!!'

CALL PressAny

SAY 'Now we want to make the two "ED" windows the current and previous hosts'
SAY 'with "COMMAND" dropped altogether. This line makes COMMAND the previous:-'Down
SAY '  'SOURCELINE(91)

ADDRESS

SAY Down'Then this line is used:-'Down
SAY '  'SOURCELINE(96)

ADDRESS 'Ed_1'

SAY Down'to make "Ed_1" (the second ED window) the CURRENT host and'
SAY '"Ed" the PREVIOUS host. "COMMAND" is lost from the list.'

CALL PressAny

SAY Down'Now we load your Startup-Sequence from RAM: into the second "ED" window.'
SAY 'with this line:-'Down
SAY '  'SOURCELINE(109)

CALL DidNotAppear

'OP "Ram:Startup-Sequence"'

CALL PressAny

SAY Down'Now we will close both "ED" windows by sending them the "X" command'
SAY 'which is an "ED" command to save the file and exit.'
SAY Down'"Ed_1" is still the current host host and it gets the first'
SAY 'command line which is:-'Down
SAY '  'SOURCELINE(122)
SAY Down'The "ED" window holding "Startup-Sequence" should close when you:-.'

CALL PressAny

'X'

SAY Down'Now we will swap the host address to the first "ED" window with this line:-'Down
SAY '  'SOURCELINE(127)

ADDRESS

SAY Down'"Ed" (the first "ED" window) should now be the CURRENT host and'
SAY '"Ed_1" (the second "ED" window) the PREVIOUS host even though it'
SAY 'no longer exists.'

SAY Down'This line:-'Down
SAY '  'SOURCELINE(140)

SAY Down'is sent to "Ed" and its window will close when you:-'

CALL PressAny

'X'

SAY Down'Finally we need to do our housekeeping by deleting the files that we'
SAY 'copied to RAM:. But "COMMAND" is no longer either the current or previous'
SAY 'hosts so we use this line:-'Down
SAY '  'SOURCELINE(147)

ADDRESS 'COMMAND'

SAY Down'to make AmigaDOS the current host.'

SAY Down'Now we send it the command line:-'Down
SAY '  'SOURCELINE(154)

'DELETE >Nil: RAM:(Startup-Sequence|Example23-3.rexx)'

SAY Down'and then the line:-'Down
SAY '  'SOURCELINE(160)
SAY Down'to show that the files have been deleted:-'Down

'DIR Ram:'

CALL PressAny

SAY Down'O.K. - ALL DONE!!'

EXIT

PressAny:

SAY Down||Bell||CENTRE('*** PRESS ANY KEY TO CONTINUE ***',75)
PULL AnyKey
RETURN

DidNotAppear:

SAY Down'If nothing appears in the "ED" window then you may have pressed a key'
SAY 'in it while it was active. Check the bottom line of "ED" to see if this'
SAY 'message has appeared:-'
SAY Down'   Edits will be lost - type Y to confirm:'
SAY Down'If so, then enter "Y" into the "ED" window then click in the Shell/CLI'
SAY 'window to make it active.'
RETURN
