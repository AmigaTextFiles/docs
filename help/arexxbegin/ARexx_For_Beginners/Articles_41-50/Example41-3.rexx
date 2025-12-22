/* Example41-3 */

Length = 20
MemAdd = GETSPACE(Length)

Text = 'String with 20 chars'
HowMuch = EXPORT(MemAdd,Text,Length)
SAY 'Number of characters written =' HowMuch
Import = IMPORT(MemAdd)
SAY 'String retrieved =' Import
SAY 'With a length of' LENGTH(Import)

Text = 'Short String'
HowMuch = EXPORT(MemAdd,Text,Length)
SAY 'Number of characters written =' HowMuch
Import = IMPORT(MemAdd)
SAY 'String retrieved =' Import
SAY 'With a length of' LENGTH(Import)
CALL FREESPACE(MemAdd,Length)
