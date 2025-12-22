/* Example20-1 */
/* Copyright © 1995 Frank Bunton */

/* Getting the "Proper" Date    */

SAY 'c'x'Producing "Proper Date" - Do you want to include day name? (Y/N)'
PULL Which

DayName = DATE('W')
Day = STRIP(RIGHT(DATE('O'),2),'L','0')
Month = DATE('M')
Year = LEFT(DATE('S'),4)

Suffix = 'th'
IF Day = 1 | Day = 21 | Day = 31 THEN Suffix = 'st'
IF Day = 2 | Day = 22 THEN Suffix = 'nd'
IF Day = 3 | Day = 23 THEN Suffix = 'rd'

ProperDate = Day||Suffix Month Year
IF Which = 'Y' THEN ProperDate = DayName ProperDate

SAY ProperDate
