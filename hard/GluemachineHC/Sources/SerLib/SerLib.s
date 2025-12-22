**************************************************************
*                           \|/                              *
*                           @ @                              *
*-----------------------ooO-(_)-Ooo--------------------------*
*                                                            *
*                      Serial library.                       *
*                        Gluemaster                          *
*                          950708                            *
*                                                            *
*------------------------------------------------------------*
*                                                            *
*                                                            *
**************************************************************
	PROCESSOR 68HC11

	XDEF InitSer
	XDEF RecSer
	XDEF TransSer

	include "ADEV11:include/hc11reg.i"

	RSEG CODE

; Initialize to a:8:1:N where a is BAUDRATE in acc. a
InitSer:
	ldx #REGBASE
	bclr SPCR,x,#DWOM
	staa BAUD,x
	ldaa #TE|RE
	staa SCCR2,x
	rts

; Recieved byte in acc. a
RecSer:
	ldx #REGBASE
RCLoop:
	brclr SCSR,x,RDRF,RCLoop
	ldaa SCDAT,x
	rts

; Byte to transmit in acc. a
TransSer:
	ldx #REGBASE
	staa SCDAT,x
WCLoop:
	brclr SCSR,x,TDRE,WCLoop
	rts

**************************************************************
*                                                            *
*-----------------------oooO---Oooo--------------------------*
*                                                            *
**************************************************************
	END
