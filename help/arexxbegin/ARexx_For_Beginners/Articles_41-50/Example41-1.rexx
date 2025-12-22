/* Example41-1 */

Length = 20
MemAdd = GETSPACE(Length)

Text = 'This string is longer than the space allocated'
HowMuch = EXPORT(MemAdd,Text,Length)
SAY 'Number of characters written =' HowMuch
SAY 'Text written was             =' IMPORT(MemAdd,Length)
CALL FREESPACE(MemAdd,Length)