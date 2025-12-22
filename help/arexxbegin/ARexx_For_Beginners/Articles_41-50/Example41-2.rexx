/* Example41-2 */

Length = 20
MemAdd = GETSPACE(Length)

Text = 'String with 20 chars'
HowMuch = EXPORT(MemAdd,Text)
SAY 'Number of characters written =' HowMuch
SAY 'String retrieved =' IMPORT(MemAdd)
Text = 'Short String'
HowMuch = EXPORT(memAdd,Text)
SAY 'Number of characters written =' HowMuch
SAY 'String retrieved =' IMPORT(MemAdd)
CALL FREESPACE(MemAdd,Length)
