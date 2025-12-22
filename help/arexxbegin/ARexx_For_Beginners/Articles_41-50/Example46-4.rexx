/* Example46-4 */

Help1 = 'Your full name with surname last should be entered here.'
Help2 = 'You phone number including STD code should be entered here.'

SAY 'This is a demonstration of a HELP function'

Name = '?'
DO WHILE Name = '?'
  OPTIONS PROMPT 'Enter your name or ? for help '
  PULL Name
  IF Name = '?' THEN DO
    SAY '1b'x'[32m'||Help1||'1b'x'[0m'
  END
END

Phone = '?'
DO WHILE Phone = '?'
  OPTIONS PROMPT 'Enter phone number or ? for help '
  PULL Phone
  IF Phone = '?' THEN DO
    SAY '1b'x'[32m'||Help2||'1b'x'[0m'
  END
END

SAY '1b'x'[32mHi there' Name 'at phone' Phone
