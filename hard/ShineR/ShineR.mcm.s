****************************************
****  ShineR - module for MCCONTROL ****
****                                ****
****    lame code by Shin of LKR    ****
****   read ShineR.README file for  ****
****          information           ****
****************************************


RRTS	MACRO
	jmp	nopp
	ENDM



;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; some things 
	rts
	dc.w	1
	dc.b	'MCCM'
	dc.l	1<<3

	ds.l	17	; some unused things :)
	
;--- Jump Table                                                 
			        
	ds.w	3	;Module_Delay                 rs.w 3


	jmp	DeviceTest		;Module_Open                  rs.w 3  
	RRTS	;Module_Close                 rs.w 3  
	RRTS	;Module_FrameOpen             rs.w 3  
	RRTS	;Module_FrameClose            rs.w 3  
	RRTS	;Module_ReadCommand           rs.w 3  
	RRTS	;Module_WriteCommand          rs.w 3  
	RRTS	;Module_PADOpen               rs.w 3  
	RRTS	;Module_PADClose              rs.w 3  
	RRTS	;Module_PADCommand            rs.w 3  
	jmp	ProcedeIO	;Module_DirectFrame           rs.w 3  
	RRTS	;Module_DirectPage            rs.w 3  

	ds.w	3*9
			
;-----------------------------------

	dc.b	'$VER: ShineR.mcm 2.0 (30.01.00) by Shin',0
	even

addrH	dc.b	0
addrL	dc.b	0



;------------------------------------------------------------
	even




;------------------------------------------------------------
;------------------------------------------------------------

nopp	moveq	#0,d0
	rts


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DeviceTest
	movem.l	d1-d7/a0-a6,-(a7)

	moveq	#4,d7
.l1	move.b	#'I',d0
	bsr	send
	bsr	get
	cmp.b	#'S',d0
	beq.s	.a1
	dbf	d7,.l1	
	moveq	#2,d0
	bra.s	.ex
.a1	moveq	#0,d0
.ex	movem.l	(a7)+,d1-d7/a0-a6
	rts


;-----------------------------------------------------------


ProcedeIO	movem.l	d1-d7/a0-a6,-(a7)
	move.w	d0,addrH
	move.l	a0,a2
	tst.b	d1
	beq.s	ReadFrame
	subq.b	#1,d1
	beq.s	WriteFrame
ExitR	movem.l	(a7)+,d1-d7/a0-a6
	rts




;-----------------------------------------------
WriteFrame	bsr	write_block
	bra.s	ExitR

write_block
	moveq	#5,d6
.rewrite	moveq	#2,d7
.head_read	move.b	#"W",d0
	bsr	send
	bsr	get
	cmp.b	#"A",d0
	beq.s	.head_cont
	dbf	d7,.head_read
	moveq	#-1,d0
	rts
.head_cont	move.b	addrH(pc),d0
	bsr	send
	move.b	addrL(pc),d0
	bsr	send
	bsr	get
	cmp.b	#"o",d0
	bne.s	.cr

	move	#(128)-1,d7
.repeat	move.b	(a2)+,d0
	bsr	send
	dbf	d7,.repeat

	bsr	get
	cmp.b	#"E",d0
	beq.s	.ok

.cr	dbf	d6,.rewrite
	moveq	#-1,d0
	rts
.ok	moveq	#0,d0
	rts


;----------------------------------------------
ReadFrame	bsr	read_block
	bra.s	ExitR


read_block	
	moveq	#5,d6
.reread	moveq	#2,d7
.head_read	move.b	#"R",d0
	bsr	send
	bsr	get
	cmp.b	#"A",d0
	beq.s	.head_cont
	bsr	get
	dbf	d7,.head_read
	moveq	#-1,d0
	rts
.head_cont	move.b	addrH(pc),d0
	bsr	send
	move.b	addrL(pc),d0
	bsr	send
	bsr	get
	cmp.b	#"o",d0
	bne.s	.cr

	move	#(128)-1,d7
.repeat	bsr	get
	move.b	d0,(a2)+
	dbf	d7,.repeat

	bsr	get
	move.b	d0,d5
	bsr	get
	cmp.b	#"E",d0
	beq.s	.ok

.error	lea	-128(a2),a2
.cr	dbf	d6,.reread
	moveq	#-1,d0
	rts

.ok	move.l	a2,a3
	moveq	#127,d4
.chk	move.b	-(a3),d3
	eor.b	d3,d5
	dbf	d4,.chk
	move.b	addrH,d3
	eor.b	d3,d5
	move.b	addrL,d3
	eor.b	d3,d5
	bne.s	.error

	moveq	#0,d0
	rts



;+++++++++++++++++++++++++++++++++++++++++++++++
;---------------------------------------------
; send
; d0 = sended byte

send
	lea	$bfe101,a1
	lea	$bfe301,a0
	move.b	#0,(a1)

	moveq	#-1,d2
	move.b	#%10000,(a0) ; clk low
	move.b	#%10000,(a0) ; clk low
.w1	moveq	#15,d1
	and.b	(a1),d1
	beq.s	.o1
	dbf	d2,.w1
	moveq	#-1,d0
	rts
.o1	move.b	#0,(a0)
	move.b	#0,(a0)
	
	not.b	d0
	move.b	d0,d1
	lsr.b	#4,d1
	or.b	#%10000,d1
	move.b	d1,(a0)
	move.b	d1,(a0)
	move.b	#0,(a0)
	move.b	#0,(a0)

	and.b	#15,d0
	or.b	#%10000,d0
	move.b	d0,(a0)
	move.b	d0,(a0)
	move.b	#0,(a0)
	move.b	#0,(a0)
	rts


get
	lea	$bfe101,a1
	lea	$bfe301,a0
	move.b	#0,(a1)

	moveq	#-1,d2
	move.b	#%10000,(a0) ; clk low
	move.b	#%10000,(a0) ; clk low
.w1	moveq	#15,d1
	and.b	(a1),d1
	beq.s	.o1
	dbf	d2,.w1
	moveq	#-1,d0
	rts
.o1	move.b	#0,(a0)
	move.b	#0,(a0)
	
	move.b	#%10000,(a0)
	move.b	#%10000,(a0)
	move.b	(a1),d1
	lsl.b	#4,d1
	move.b	#0,(a0)
	move.b	#0,(a0)

	move.b	#%10000,(a0)
	move.b	#%10000,(a0)
	moveq	#15,d0
	and.b	(a1),d0
	move.b	#0,(a0)
	move.b	#0,(a0)
	or.b	d1,d0
	rts


