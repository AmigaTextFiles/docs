/* Example41-4 */

Length = 20
MemAdd = GETSPACE(Length)

Text = 'String with'||'0'x||' 20 char'
SAY 'Symbol "Text" =' Text
SAY 'And it is' LENGTH(Text) 'characters long'

HowMuch = EXPORT(MemAdd,Text,Length)
SAY 'Number of characters written =' HowMuch
Import = IMPORT(MemAdd)
SAY 'Imported string =' Import
SAY 'And it is' LENGTH(Import) 'characters long'
CALL FREESPACE(MemAdd,Length)
