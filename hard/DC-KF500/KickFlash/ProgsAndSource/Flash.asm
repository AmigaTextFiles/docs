
	MACHINE	68000

	SECTION	FLASH,CODE

	XDEF	_ERASE
	XDEF	_WRITE
	XREF	_KICK		;GLOBAL POINTER TO KICKSTART IMAGE

* Erase function takes no parameters, and does a sector erase on 
* the relevant portions of the chips. Since A18 is controlled by
* switch 3 , we don't need to worry about erasing the wrong sectors
* in the chips.




_ERASE:	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.W	#$F0F0,$F80000		; Send chips a reset command


* FOLLOWING IS THE COMMAND SEQUENCE TO INITIATE A SECTOR ERASE

	MOVE.W	#$AAAA,$F80AAA
	MOVE.W	#$5555,$F80554
	MOVE.W	#$8080,$F80AAA
	MOVE.W	#$AAAA,$F80AAA
	MOVE.W	#$5555,$F80554

* THEN WRITE THE ACTUAL SECTOR BLOCK ERASE COMMANDS

	MOVE.W	#$3030,$F80000	;our accesses are always within 50us
	MOVE.W	#$3030,$FA0000	;so we don't need to check DQ3 bit.
	MOVE.W	#$3030,$FC0000
	MOVE.W	#$3030,$FE0000

* See how the operation is going

STAT:	MOVE.W 	$E00000,D0	;/OE IS VALID AT $E00000-$E7FFFF
	MOVE.W	D0,D1	
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMPI.B 	#$80,D0		;Check both chips finished
	BEQ	PASS1		; ERASED SUCCESSFULLY	

	MOVE.W	D1,D0
	ANDI.W	#$2020,D0	;mask all but bits 5 of each chip.
	CMPI.B	#$20,D0
	BNE	STAT		; CHIPS NOT TIMED OUT YET

	MOVE.W 	$E00000,D0	; read it again since DQ5,7 can change
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMPI.B 	#$80,D0	
	BEQ	PASS1		
	BNE	FAIL		; TIMED OUT, AND DATA NOT VALID

PASS1:	MOVE.W 	$E00000,D0	;/OE IS VALID AT $E00000-$E7FFFF
	ROR.W	#$8,D0
	MOVE.W	D0,D1	
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMPI.B 	#$80,D0		;Check both chips finished
	BEQ	PASS		; ERASED SUCCESSFULLY	

	MOVE.W	D1,D0
	ANDI.W	#$2020,D0	;mask all but bits 5 of each chip.
	CMPI.B	#$20,D0
	BNE	PASS1		; CHIPS NOT TIMED OUT YET

	MOVE.W 	$E00000,D0	; read it again since DQ5,7 can change
	ROR.W	#$8,D0
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMPI.B 	#$80,D0	
	BEQ	PASS		
	BNE	FAIL		; TIMED OUT, AND DATA NOT VALID


PASS:	MOVEM.L	(SP)+,D1-D7/A0-A6
	MOVEQ	#1,D0		;PASSED!
	RTS

FAIL:	MOVEM.L	(SP)+,D1-D7/A0-A6
	MOVE.W	#$F0F0,$F80000		; Send chips a reset command
	MOVEQ	#0,D0		;FAILED!
	RTS


* Write takes no parameters, returns true if successfull
* Uses global variable KICK to start reading Kickstart data
* from.

* A0 = Source data ptr
* A1 = Dest data ptr
* D0 = temp
* D1 = temp
* D2 = temp
* D4 = Loop counter

_WRITE:	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.W	#$F0F0,$F80000		; Send chips a reset command

	MOVEA.L	_KICK,A0		;pointer to kickstart image
	MOVEA.L	#$F80000,A1		;START OF FLASH AREA
	MOVE.L	#$40000,D4		; 256K WORDS = 512K BYTES

LOOP:	MOVE.W	(A0)+,D0
	MOVE.W	D0,D2
	ANDI.W	#$8080,D2			;SAVE BIT 7 OF DATA WRITTEN

* FOLLOWING IS THE COMMAND SEQUENCE TO INITIATE A DATA WRITE
* Routine assumes that ERASE has already been carried out.
* Will fail harmlessly with an error if not.

	MOVE.W	#$AAAA,$F80AAA
	MOVE.W	#$5555,$F80554
	MOVE.W	#$A0A0,$F80AAA

	MOVE.W	D0,(A1)		;ACTUALLY WRITE THE WORD TO FLASH

	MOVEA.L	A1,D3
	AND.L	#$E7FFFF,D3	; MASK A19,A20 OUT (F8->E0)
	MOVEA.L	D3,A2

* Check Low byte, then High Byte

STATL:	MOVE.W 	(A2),D0		;/OE IS VALID AT $E00000-$E7FFFF
	MOVE.W	D0,D1	
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMP.B	D0,D2		; CHECK THE BIT 7'S OF LOW CHIPS
	BEQ	PASSL		;DATA IS VALID

	MOVE.W	D1,D0
	ANDI.W 	#$2020,D0	;mask all but bits 5 of each chip.
	CMPI.B	#$20,D0
	BNE	STATL		; CHIPS NOT TIMED OUT YET

	MOVE.W 	(A2),D0		; read it again since DQ5,7 can change together
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMP.B	D0,D2		; CHECK THE BIT 7'S OF LOW CHIPS	
	BEQ	PASSL		
	BNE	FAILW		; TIMED OUT, AND DATA NOT VALID

PASSL:	ROR.W	#$8,D2		; Check high part of the word
	MOVE.W 	(A2),D0		;/OE IS VALID AT $E00000-$E7FFFF
	ROR.W	#$8,D0
	MOVE.W	D0,D1	
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMP.B	D0,D2		; CHECK THE BIT 7'S OF HIGH CHIPS
	BEQ	PASSW		;DATA IS VALID

	MOVE.W	D1,D0
	ANDI.W 	#$2020,D0	;mask all but bits 5 of each chip.
	CMPI.B	#$20,D0
	BNE	PASSL		; CHIPS NOT TIMED OUT YET

	MOVE.W 	(A2),D0		; read it again since DQ5,7 can change
	ROR.W	#$8,D0
	ANDI.W 	#$8080,D0	;mask all but bits 7 of each chip.
	CMP.B	D0,D2		; CHECK THE BIT 7'S OF HIGH CHIPS	
	BEQ	PASSW		
	BNE	FAILW		; TIMED OUT, AND DATA NOT VALID


PASSW:	ADDA.L	#2,A1		; BUMP FLASH POINTER
	SUBQ.L  #1,D4
	BNE	LOOP		; MORE DATA STILL TO GO?
	MOVEM.L	(SP)+,D1-D7/A0-A6
	MOVEQ	#1,D0		;PASSED!
	RTS

FAILW:	MOVEM.L	(SP)+,D1-D7/A0-A6
	MOVEQ	#0,D0		;FAILED!
	RTS