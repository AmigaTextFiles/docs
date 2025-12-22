/* Example47-6 */

CALL TRACE('I')

Input = 'Jack Spratt and his wife'
PARSE VAR Input First Second .
Count = 1
Name.Count = First
Count = Count + 1
Name.Count = Second
Count = -Count + 3
SAY UPPER(Name.Count)
