/* Example23-5 */

SAY 'Following is the directory of the RAM: disk'
ADDRESS 'COMMAND'            /* AmigaDOS is now the current host        */
'RUN ED Dummy'               /* Set up an ED window                     */
'Copy Example23-5.rexx RAM:' /* Copy this program to RAM:               */
'Dir Ram:'                   /* The DIR command is sent to AmigaDOS     */

ADDRESS 'Ed' 'OP "Ram:Example23-5.rexx"'  /* A command is sent to ED
                                          without changing current host */

SAY 'a'x'PRESS ANY KEY TO CONTINUE'||'a'x
PULL Anything

'DELETE Ram:Example23-5.rexx' /* AmigaDOS is still the host address     */

ADDRESS 'Ed' 'Q' /* Another command to ED without changing host address */
