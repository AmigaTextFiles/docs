/* Example16-9.rexx */

/* Main Part 1 */

MyName = 'Fred Bloggs'
SAY 'My name is (ex Main Part1.1)  ' MyName
CALL Function_1
SAY 'My name is (ex Main Part1.2)  ' MyName

/* Main Part 2 */

MyName = 'Jack Spratt'
SAY 'My name is (ex Main Part2.1)  ' MyName
CALL Function_2
SAY 'My name is (ex Main Part2.2)  ' MyName

EXIT

Function_1:
  MyName = 'Jane Doe'
  SAY 'My name is (ex Function-1)' MyName
RETURN

Function_2:
  PROCEDURE
  MyName = 'Jane Doe'
  SAY 'My name is (ex Function-2)' MyName
RETURN
