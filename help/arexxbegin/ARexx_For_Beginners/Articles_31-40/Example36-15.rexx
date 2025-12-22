/* Example 36-15 */
/* Check Screen Mode */

SAY 'Checking for PAL or NTSC boot - If NTSC I will abort startup'

PARSE VERSION VersionString

Video = WORD(VersionString,5)

IF UPPER(Video) = 'NTSC' THEN DO
  SAY 'System has booted with an NTSC screen - You need to reboot now!'
  DO FOREVER ; END
END
ELSE SAY 'All OK - PAL detected - startup proceeding'
