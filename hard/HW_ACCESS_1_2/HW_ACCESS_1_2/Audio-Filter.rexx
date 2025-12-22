/* Direct HW programming using ARexx; the audio filter switch. */
/* Run from a Shell or CLI only, type 'RX Audio-Filter.rexx[RETURN/ENTER]' */
/* without the quotes. Bit 1 of register 0xBFE001 is set to 1 to turn the */
/* filter OFF and set to 0 to turn the filter ON. The 'ddra' register for */
/* this facility is set up correctly during bootup so no need to alter it */
/* at this point; this 'ddra' register is 0xBFE201 and is set to 0x03. */

/* Set up any constants or variables. */
  copyright='9'x'$VER: Audio-Filter.rexx_Version_1.00.00_20-09-2006_(C)G0LCU.'

/* Use ECHO for ordinary printing to the screen and SAY for printing results. */
  DO FOREVER
    ECHO 'c'x
    SAY copyright
    ECHO 'a'x'd'x'9'x'9'x'1) Audio filter and power light bright or on.'
    ECHO '9'x'9'x'2) Audio filter and power light dim or off.'
    ECHO 'a'x'd'x'9'x'9'x'3) Quit this program.'
    ECHO 'a'x'd'x'9'x'9'x'Type in a number and then press ENTER/RETURN:-'
    PULL number
    IF number='1' THEN CALL lighton
    IF number='2' THEN CALL lightoff
    IF number='3' THEN CALL getout
  END

/* Turn the audio filter and power light on or up. */
lighton:
  EXPORT('00BFE001'x,'FC'x,1)
  RETURN

/* Turn the audio filter and power light off or down. */
lightoff:
  EXPORT('00BFE001'x,'FE'x,1)
  RETURN

/* Exit the program safely. */
getout:
  EXPORT('00BFE001'x,'FC'x,1)
  EXIT(0)
