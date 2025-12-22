/* Example27-5.rexx */

cls = 'c'x
cd  = 'a'x

DO FOREVER

  SAY cls'Select a menu item and press return'
  SAY cd'1. Menu Item 1'
  SAY '2. Menu Item 2'
  SAY '3. Menu Item 3'
  SAY cd'Q  to quit'
  PULL Menu
  IF Menu = 'Q' THEN EXIT
  SELECT
     WHEN Menu = 1 THEN CALL Menu1
     WHEN Menu = 2 THEN CALL Menu2
     WHEN Menu = 3 THEN CALL Menu3
     OTHERWISE DO
        SAY cd'No Such Menu Item - Try Again!'
        CALL PressAny
        ITERATE
     END
  END
END
EXIT

Menu1:
SAY cls'I''M AT MENU ITEM 1'
CALL PressAny
RETURN

Menu2:
SAY cls'I''M AT MENU ITEM 2'
CALL PressAny
RETURN

Menu3:
SAY cls'I''M AT MENU ITEM 3'
CALL PressAny
RETURN

PressAny:
OPTIONS PROMPT cd'Press Any Key to Continue'
PULL trash
OPTIONS PROMPT
RETURN
