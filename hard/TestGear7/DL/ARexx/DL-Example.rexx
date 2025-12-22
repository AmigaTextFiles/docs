/* A simple test for finding the address of the data aquired by the DL. */
/* (C)2006, B.Walker, G0LCU and A.Hoffman. */

ECHO 'c'x'(A simple ARexx DEMO program using an IconX window for STDOUT.)'
ECHO 'a'x'Finding the data address of the Data Logger using ARexx.'
ECHO 'a'x'This uses address 0, the SSP, to store the data address,'
ECHO 'AND, IS an ENFORCER hit!!!'

/* This line is much the same as ~LET addr&=PEEKL(0)~ in AmigaBASIC. */
addr = IMPORT('00000000'x,4)

/* This line converts the string to hexadecimal. */
SAY 'a'x'The data address is at '||C2X(addr)||'H.'

ECHO 'a'x'The maximum data size is 512 Bytes inside a total user space'
ECHO 'of 16384 Bytes.'
EXIT
