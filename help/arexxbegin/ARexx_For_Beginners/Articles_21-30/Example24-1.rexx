/* Example24-1 */

CALL OPEN('Window','CON:20/100/600/50/A WINDOW TO TEST ADDRESS()')
CurrentHost = ADDRESS()
CALL WRITELN('Window','Current host address is' CurrentHost)
CALL WRITELN('Window','a'x'This window will close by itself in 5 seconds')
CALL TIME('R')
DO WHILE TIME('E') < 5
END
CALL CLOSE('Window')
