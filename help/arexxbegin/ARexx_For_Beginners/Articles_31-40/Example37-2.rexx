/* Example37-2 */

DO Count = 1 to 2

  SAY 'Details of Person' Count 'are:-'
  SAY '    Name =' GETCLIP('Person.'||Count)
  SAY '   Phone =' GETCLIP('Phone.'||Count)

END
