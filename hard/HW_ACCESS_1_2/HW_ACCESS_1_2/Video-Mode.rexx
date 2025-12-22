/* Direct HW programming using ARexx; the video mode switch. */
/* Run from a Shell or CLI only, type 'RX Video-Mode.rexx[RETURN/ENTER]' */
/* without the quotes. Bit 5 of register 0xDFF1DC is set to 0 to switch */
/* the video mode to NTSC and reset to 1 to switch the video mode to PAL. */

/* Set up any constants or variables. */
  copyright='9'x'$VER: Video-Mode.rexx_Version_1.00.00_20-09-2006_(C)G0LCU.'

/* Use ECHO for ordinary printing to the screen and SAY for printing results. */
  DO FOREVER
    ECHO 'c'x
    SAY copyright
    ECHO 'a'x'd'x'9'x'9'x'0) Video mode set to NTSC.'
    ECHO '9'x'9'x'1) Video mode set to PAL.'
    ECHO 'a'x'd'x'9'x'9'x'2) Quit this program.'
    ECHO 'a'x'd'x'9'x'9'x'Type in a number and then press ENTER/RETURN:-'
    PULL number
    IF number='0' THEN CALL ntsc
    IF number='1' THEN CALL pal
    IF number='2' THEN CALL getout
  END

/* Switch the video mode to NTSC. */
ntsc:
  EXPORT('00DFF1DC'x,'00'x,1)
  RETURN

/* Switch the video mode to PAL. */
pal:
  EXPORT('00DFF1DC'x,'20'x,1)
  RETURN

/* Exit the program safely. */
getout:
  EXIT(0)
