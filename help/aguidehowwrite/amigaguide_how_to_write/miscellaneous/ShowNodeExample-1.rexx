/* Example 1 - Script For Showing an Amigaguide Node */

Down = 'a'x

NodeName.1   = 'ASCII Codes'
Nodename.1.1 = 'Ascii'
NodeName.2   = 'Line Feed Character'
NodeName.2.1 = 'LineFeed'
NodeName.3   = 'Commands'
NodeName.3.1 = 'Commands'
NodeName.4   = 'Commands - Global'
NodeName.4.1 = 'Global'
NodeName.5   = 'Commands - Local'
NodeName.5.1 = 'Local'
NodeName.6   = 'Commands - Text Attribute'
Nodename.6.1 = 'Attribute'
NodeName.7   = 'Lines - Logical'
NodeName.7.1 = 'Logical'
NodeName.8   = 'Lines - Physical'
NodeName.8.1 = 'Physical'
NodeName.9   = 'Nodes'
NodeName.9.1 = 'Nodes'

/******************************
 * Add the amigaguide.library *
 ******************************/

IF ~EXISTS('Libs:amigaguide.library') THEN DO

  SAY 'Libs: directory does not contain the amigaguide.library file'
  EXIT

END

IF ~SHOW('L','amigaguide.library') THEN DO

  CALL ADDLIB('amigaguide.library',0,-30)

END

/*****************
 * Set file name *
 *****************/

FileName = 'AGHTW:AGHTW_Part5'

/************************
 * Check if file exists *
 ************************/

IF ~EXISTS(FileName) THEN DO

  SAY Down||' 'FileName 'not found.'Down,
  'Did you click on the button to make the assignment AGHTW:?'Down

  EXIT

END

/*****************
 * Get Node Name * 
 *****************/

DO FOREVER

  SAY Down'Press the number of the GLOSSARY item to read or Q to quit'Down

  DO Count = 1 TO 9 ; SAY '   'Count'. 'NodeName.Count ; END

  PULL Count

  IF UPPER(Count) = 'Q' THEN LEAVE

  IF Count < 1 | Count > 9 THEN DO

    SAY Down'Invalid number' count 'entered - try again'
    ITERATE

  END

  /*****************
   * Call Shownode *
   *****************/

  CALL SHOWNODE(,FileName,NodeName.Count.1,,)
  
END

CALL REMLIB('amigaguide.library')
