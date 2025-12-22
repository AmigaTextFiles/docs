/* 
 TAPE CUEING SCRIPT USING RC-10_REXX PORT - - SURE HOPE IT WORKS

** This is an example of how to use Trek-The Guide for cueing up
** your favorite episodes. It uses the InfraRexxDaemon as its VCR controller
** and also assumes your controlling a VCR capable of doing a 'Time Search'
** such as a medium to high end Panasonic VCR does. The format and arguments
** are as follows:  'rx VCR.rexx 016 02 1 4 6'
** 016 is the tape number
** 02 is the cut number
** 1 is the the hour unit
** 4 is the tens of minutes unit
** 6 is in the ones unit
** 
** so the time to search in this case is 1 hour 46 minutes.
** NOTE: See InfraRexx docs for details on that end.
*/

if ~show('L','rexxarplib.library') then
	call addlib('rexxarplib.library',0,-30)

/* tn is tape number, cn is tape cut number c1, c2, & c3 are the times ie 2:34
** written as 2 3 4 */

arg tn cn c1 c2 c3 .

request = Request(200, 200, 'Please insert Tape #'tn '\and rewind to the beginning.\ \   CLICK OKAY WHEN READY.\',, Okay, Cancel, TREKGUIDE)

if request = OKAY THEN DO
address INFRAREXX

address INFRAREXX
address INFRAREXX VID_TIME_SEARCH
call delay(20)

address INFRAREXX 'VID_'c1
call delay(5)

address INFRAREXX 'VID_'c2
call delay(5)

address INFRAREXX 'VID_'c3
call delay(5)

address INFRAREXX VID_FAST_FORWARD

/*address command 'run c:echo >speak:' "now cueing tape number" tn " to cut number" cn */
call = Request(200, 200, 'Cueing tape number 'TN' to cut 'cn,, Okay,, TREKGUIDE)
END

