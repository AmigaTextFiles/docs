/* Example3-2.rexx */

PARSE ARG Name','Age

IF Name = '' | Age = '' THEN DO

  SAY 'You should have put your name and age after the RX Example3-2'
  EXIT

END

SAY 'Hi there' Name||'. You say you are' Age' years old.'
