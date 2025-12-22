/* A test ARexx Program for Multiview/Amigaguide */

CALL CLOSE('STDOUT')
CALL OPEN('STDOUT','CON:50/60/510/70/TEST WINDOW FOR MULTIVIEW AREXX PROGRAM')
SAY 'a'x||' You have just SELECTED the node about ONOPEN and ONCLOSE'
SAY 'a'x'        This window should  go away in 4 seconds.'

DO WHILE TIME('E') < 4
END

CLOSE('STDOUT')
EXIT
