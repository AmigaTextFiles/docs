/* Example47-5 */

CALL TRACE('R')

Input = 'Jack Spratt and his wife'
PARSE VAR Input First Second .
Count = 1
Name.Count = First
Count = Count + 1
Name.Count = Second
Count = -Count + 3
SAY UPPER(Name.Count)
