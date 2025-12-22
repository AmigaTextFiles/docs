/* 
**---------------------------------------
**
** AMIL_Contrib_YAM.rexx
**
** Send AMIL contribution using YAM by M. Beck.
**
** © 1996 Tassos Hadjithomaoglou
**
**----------------------------------------
** $VER: AMIL_Contrib_YAM.rexx V0.1 (28-Apr-96)
**----------------------------------------
**
** History
**
**  0.1 First release.
**
**------------------------------------------------------------------------
*/

/*
** SendNow variable
**
** Select whether to SEND the contribution NOW or put it into the QUEUE
** and sent it later.
** That's the only thing you should change.
**
** SendNow = 1 ; Send the mail now (A TCP/IP stack must be running !!!).
** SendNow = 0 ; Put the mail into the queue and send it later (Default).
*/

SendNow = 0

/*
** Please don't change anything after this line
**----------------------------------------------
*/

OPTIONS RESULTS

SIGNAL ON BREAK_C
SIGNAL ON SYNTAX

NL='0A'X

Contrib_file = 'T:AMIL_Contrib.txt'

/*
** Check if YAM is running. If not, start it in iconified mode.
** Please make sure the YAM: assign is made
** and that it points to the right directory.
*/

IF ~SHOW('Ports','YAM') THEN
DO
 	ADDRESS COMMAND 'Run YAM:YAM NOCHECK HIDE'
	ADDRESS COMMAND 'SYS:RexxC/WaitForPort YAM'
END

/*
** Compose the mail header and send/queue the mail.
*/

IF SHOW('Ports','YAM') THEN
DO
		ADDRESS 'YAM'
		WriteMailTo "chatasos@cs.teiath.gr"
		WriteSubject "AMIL"
		WriteLetter Contrib_file
		IF SendNow THEN
		DO
			WriteSend
			SAY 'Mail sent...'
		END
		ELSE
		DO
			WriteQueue
			SAY 'Mail queued...'
			SAY 'Run YAM at a later time to send it.'
		END

		/*
		ADDRESS COMMAND 'Delete >NIL: 'Contrib_file
		*/
END
ELSE
DO
	SAY 'Error while loading YAM.'
	SAY 'Check file YAM:YAM and try again later.'
END

EXIT 0

/*
** Handle the Error condition
*/

SYNTAX:
	SAY 'Error at line' SIGL ':' ERRORTEXT(RC)
	SAY 'Please report it to the author'
	EXIT

/*
** Handle the Control C command given by the user
*/

BREAK_C:
	SAY 'Sending AMIL Contribution with YAM aborted...'
	EXIT
