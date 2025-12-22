/* Example56-3 Script For Showing an Amigaguide Node on DOPUS screen */

Down = 'a'x

/******************************
 * Add the amigaguide.library *
 ******************************/

IF ~EXISTS('Libs:amigaguide.library') THEN DO

  SAY 'Libs: directory does not contain the amigaguide.library file'
  EXIT

END

IF ~SHOW('L','amigaguide.library') THEN DO

  CALL ADDLIB('amigaguide.library',0,-30,0)

END

/**************************************
 * Set Names Of Screen, File and Node *
 **************************************/

ScreenName = 'DOPUS.1'
FileName   = 'DOPUS5:Help/Dopus5.guide'
NodeName   = 'Encrypt'

/************************
 * Check if file exists *
 ************************/

IF ~EXISTS(FileName) THEN DO

  SAY Down||' 'FileName 'not found.'Down,
  'Do you have Directory Opus version 5 or higher running'Down,
  'and is the assignment to Dopus5: still in effect?'Down

  EXIT

END

/*****************
 * Call Shownode *
 *****************/

CALL SHOWNODE(ScreenName,FileName,NodeName,,)
  
CALL REMLIB('amigaguide.library')































