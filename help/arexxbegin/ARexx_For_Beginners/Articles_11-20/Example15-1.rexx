/* Example15-1.rexx */

Cls    = 'c'x                        /* Clear screen             */
Cdown  = 'a'x                        /* Cursor Down              */
Bell   = '7'x                        /* Sound bell               */
Header = Cls'THIS IS A HEADING'      /* Put header on each page  */

SAY Header
SAY Cdown'Window has been cleared by header and there is a blank line above me.'
SAY '9'x'This starts 8 places out.'
SAY '8'x'My First character is on the previous line.'
SAY Bell'Bell or Screen flash with this line.'
SAY 'This line will not appear.'
SAY 'b'x'As it is covered with this one.'
SAY 'This line is followed by' 'b'x
SAY '9'x'9'x'9'x' This line.'
