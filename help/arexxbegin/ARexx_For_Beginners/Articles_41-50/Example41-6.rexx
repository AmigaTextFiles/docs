/* Example41-6 */

Length = 20
MemAdd = GETSPACE(Length)

HowMuch = EXPORT(MemAdd,,Length,'*')
SAY 'Number of characters written =' HowMuch
SAY IMPORT(MemAdd,Length)

CALL FREESPACE(MemAdd,Length)
