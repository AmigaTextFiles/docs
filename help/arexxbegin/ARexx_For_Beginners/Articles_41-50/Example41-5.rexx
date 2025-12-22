/* Example41-5 */

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
Import = IMPORT(MemAdd,Length)
SAY 'String retrieved =' Import
SAY 'With a length of' LENGTH(Import)
Stripped = STRIP(Import,'T','0'x)
SAY 'Stripped String =' Stripped
SAY 'With a length of' LENGTH(Stripped)

CALL FREESPACE(MemAdd,Length)
