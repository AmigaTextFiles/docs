/* Example30-1.rexx */

/* Phone Book Program */

/* ===================================================================== */
/* Symbol Table */

cd = 'a'x  /* cursor down one line */
cl = 'c'x  /* clear the screen */
itab = COPIES(' ',25)
mtab = COPIES(' ',28)
Heading = cl||cd||CENTRE('MY PHONE BOOK',77)||cd

Item.1 = itab'Surname      : '
Item.2 = itab'Given Name   : '
Item.3 = itab'Phone Number : '
Item.4 = itab'Comments     : '

Menu.1 = 'Enter  New People'
Menu.2 = 'Save File to Disk'
Menu.3 = 'Display  a Person'
Menu.4 = 'Quit  the Program'

Name.x.y = /* Compound Symbols to hold people's details where: */
           /* x = number of person from 1 to value held by symbol People */
           /* y = item for person from 1 to 4 */

Again  =     /* Value tells if to repeat loop for input new people */
Match  =     /* Value of Match will indicate if a person has been found */
Count  =     /* Loop counter */
Number =     /* Number of Person being Displayed or Loaded or Saved */
People = 0   /* Number of people in file */

SaveFile = 0 /* Flag to show if file need saving 1=yes 0=no */
Selection =  /* Selection from a menu */
Trash =      /* Trash symbol to use and discard */

/* ===================================================================== */

/* Check if file is on disk */

DO WHILE EXISTS('PhoneBook.Data') = 0

  SAY Heading
  SAY 'Data File does not exists. Please select an option'
  SAY cd'1. Create new File'
  SAY cd'2. Replace with correct disk'
  SAY cd'3. Abort Program'
  PULL Selection

  SELECT

    WHEN Selection = 1 THEN DO
      CALL OPEN('LogFile','PhoneBook.Data','W')
      CALL WRITELN('LogFile',0)
      CALL CLOSE('LogFile')
    END

    WHEN Selection = 2 THEN DO
      SAY 'Place correct disk in drive then press RETURN'
      CALL PressReturn
    END

    WHEN Selection = 3 THEN EXIT

    OTHERWISE DO
      SAY 'Wrong Selection - Try Again'
      CALL PressReturn
    END
  END
END

/* ===================================================================== */

/* Load File From Disk */

CALL OPEN('LogFile','PhoneBook.Data','R')

People = READLN('LogFile')

IF People > 0 THEN DO Number = 1 TO People
  DO Count = 1 TO 4
    Name.Number.Count = READLN('LogFile')
  END
END

CALL CLOSE('LogFile')

/* ===================================================================== */

/* Main Menu */

DO FOREVER
  SAY Heading
  DO Count = 1 TO 4
    IF People = 0 & (Count = 2 | Count = 3) THEN ITERATE
    SAY mtab||Count'.' Menu.Count
  END
  PULL Selection

  SELECT
    WHEN Selection = 1 THEN CALL NewPeople
    WHEN Selection = 2 & People > 0 THEN CALL SaveFile
    WHEN Selection = 3 & People > 0 THEN CALL Display
    WHEN Selection = 4 THEN CALL Quit
    OTHERWISE NOP
  END
END

/* ===================================================================== */

/* Enter New Names */

NewPeople:

DO WHILE Again ~= 'N'

  People = People + 1
  SAY Heading
  SAY CENTRE('Enter details  for new person number' People,77)
  SAY CENTRE('or RETURN at any BLANK prompt to abort an entry',77)||cd
  DO Count = 1 TO 4
    OPTIONS PROMPT Item.Count
    PARSE PULL Name.People.Count
    IF Name.People.Count = '' THEN DO
      SAY cd||CENTRE('Aborting entry for Person number' People,77)
      DO Count2 = 1 TO 4
        DROP Name.People.Count2
      END
      People = People - 1
      LEAVE Count
    END
  END

  OPTIONS PROMPT cd||CENTRE('Any more new people? (Y/N)',77)
  PULL Again
END

DROP Again
SaveFile = 1

RETURN

/* ===================================================================== */

/* Save file to disk */

SaveFile:

SAY Heading
SAY CENTRE('Saving File to Disk',77)

CALL OPEN('LogFile','PhoneBook.Data','W')

CALL WRITELN('LogFile',People)

DO Number = 1 TO People
  DO Count = 1 TO 4
    CALL WRITELN('LogFile',Name.Number.Count)
  END
END

CALL CLOSE('LogFile')

SaveFile = 0
SAY cd||CENTRE('File has now  been saved',77)

CALL PressReturn

RETURN

/* ===================================================================== */

Display:

SAY Heading

Number = 1

/* Start Main Display Loop */

DO FOREVER

/* Start Main Sub Loop */

  DO FOREVER
    SAY Heading
    SAY CENTRE('Person number' Number 'of' People 'people',77)||cd
    DO Count = 1 TO 4
      SAY Item.Count Name.Number.Count
    END

    SAY
    IF Number < People THEN SAY CENTRE('RETURN  Advance one person',75)
    IF Number > 1 THEN SAY CENTRE('SPACE   Go back one person',75)
    SAY cd||CENTRE('F  Jump to first name',75)
    SAY CENTRE('L  Jump to last  name',75)
    SAY CENTRE('M  Go  to  Main  Menu',75)
    SAY CENTRE('Q  Quit  the  Program',75) 
    OPTIONS PROMPT cd||CENTRE('Enter option OR new person''s name OR 1st two or more characters of name',77)||cd"   "
    PULL Who
    IF Who = 'M' THEN RETURN
    IF Who = 'Q' THEN DO CALL Quit
    IF Who = 'F' THEN Number = 1
    IF Who = 'L' THEN Number = People
    IF Who == ''  THEN Number = Number + 1
    IF Who == ' ' THEN Number = Number - 1
    IF Number < 1 | Number > People THEN DO
      SAY cd||CENTRE('Sorry - No more people - Press Return',77)
      OPTIONS ; PULL Trash
      IF Number < 1 THEN Number = 1
      IF Number > People THEN Number = People
    END

    IF LENGTH(Who) >1 THEN LEAVE
  END

/* End Main Sub Loop */

  Len = LENGTH(Who) ; Match = 0
  DO Count = 1 TO People
    IF Who = LEFT(UPPER(Name.Count.1),Len) THEN DO
    Match = Count ; LEAVE ; END
  END  

  IF Match = 0 THEN DO
    SAY
    SAY CENTRE('You entered' Who 'but there is no match in file',77)
    CALL PressReturn
  END
  ELSE Number = Match

END

/* End Main Display Loop */

/* ===================================================================== */

PressReturn:

OPTIONS PROMPT cd||CENTRE('Press RETURN to continue',77)
PULL Trash
RETURN

/* ===================================================================== */

/* Quit the Program */

Quit:

IF SaveFile = 1 THEN DO
  SAY cd||CENTRE('File has been changed  but has not been saved',77)
  OPTIONS PROMPT cd||CENTRE('Do you want to save it before quitting? (Y/N)',77)
  PULL YesNo
  IF YesNo ~= 'N' THEN CALL SaveFile
END

OPTIONS PROMPT cd||CENTRE('Quitting Program - Are you sure? (Y/N)',77)
Pull YesNo
IF YesNo ~= 'Y' THEN RETURN

EXIT

/* ===================================================================== */
