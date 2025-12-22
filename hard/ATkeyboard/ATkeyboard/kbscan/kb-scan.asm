
;This program is a very lame example of how to handle the Amiga.
;I use _LVODisable & idiotic loops instead of interrupts to control
;the paralellport & i'm not very proud of it but it works.
;This program is not supposed to be used very often so I think
;that's an excuse for not making it any better than this.

	incdir	LVO:
	include	dos_lib.i
	include	exec_lib.i
	include cia_lib.i
	include misc_lib.i
	incdir	include:
	include	exec/types.i
	include	dos/dos.i
	include	devices/timer.i
	include	resources/misc.i
	include	resources/cia.i
	include	hardware/cia.i


	;link with amiga.lib
	xref	_CreatePort
	xref	_DeletePort
	xref	_CreateExtIO
	xref	_DeleteExtIO
	xdef	_SysBase
	xdef	_DOSBase

dat_out	equ	0
clk_out	equ	1
clk_in	equ	3
dat_in	equ	2

ciaa_pra	equ	$bfe001
ciaa_prb	equ	$BFE101
ciab_pra	equ	$BFD000
ciaa_ddra	equ	$bfe201
ciaa_ddrb	equ	$BFE301
ciab_ddra	equ	$BFD200

	STRUCTURE kb,0
	APTR	msgport
	APTR	ioreq
	APTR	__usp
	APTR	Misc_Base
	APTR	dos_base
	APTR	exec_base
	APTR	out_hndl
	APTR	arg_ptr
	ULONG	arg_size
	UWORD	_s_byte
	LABEL	bss_size

	STRUCTURE T_REQ,IO_SIZE
	ULONG	_TV_SECS
	ULONG	_TV_MICRO
	LABEL	_IOTV_SIZE

	section	start,code_p

	lea	data_zone,a4
	move.l	sp,__usp(a4)
	move.l	a0,arg_ptr(a4)
	move.l	d0,arg_size(a4)
	movea.l	4.w,a6
	move.l	a6,exec_base(a4)

	lea	D_NAME(pc),a1
	moveq	#0,d0
	jsr	_LVOOldOpenLibrary(a6)
	move.l	d0,dos_base(a4)
	beq	free0

	movea.l	d0,a6
	jsr	_LVOOutput(a6)
	move.l	d0,out_hndl(a4)
	move.l	d0,d1
	lea	txt(pc),a1
	move.l	a1,d2
	moveq	#txt_end-txt,d3
	jsr	_LVOWrite(a6)

	movea.l	arg_ptr(a4),a0
	move.l	arg_size(a4),d0
	cmpi.b	#$a,(a0)
	beq	no_arg
	clr.b	-1(a0,d0)

	movea.l	exec_base(a4),a6
	lea	M_NAME(pc),a1
	jsr	_LVOOpenResource(a6)
	move.l	d0,Misc_Base(a4)
	beq	free1

	movea.l	d0,a6
	lea	Name(pc),a1
	moveq	#MR_PARALLELPORT,d0
	jsr	MR_AllocMiscResource(a6)
	tst.l	d0
	bne	free1

	lea	Name(pc),a1
	moveq	#MR_PARALLELBITS,d0
	jsr	MR_AllocMiscResource(a6)
	tst.l	d0				;success = 0
	bne	free2

;=========== Now we write the hardware addresses directly ===============
;---CIAA port B clk out =bit 1 dat out =bit 0 (a 1 bit means that pin is an out)-----
	move.b	#%00000011,ciaa_ddrb
;----make BUSY, SEL, POUT lines "inputs" on CIAA port A---
	andi.b	#$FF,ciab_ddra

	clr.l	-(sp)
	clr.l	-(sp)
	jsr	_CreatePort
	move.l	d0,msgport(a4)
	beq	free5
	moveq	#_IOTV_SIZE,d1
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	jsr	_CreateExtIO
	move.l	d0,ioreq(a4)
	beq	free6
	movea.l	d0,a1
	lea	T_NAME(pc),a0
	moveq	#UNIT_MICROHZ,d0
	moveq	#0,d1
	movea.l	exec_base(a4),a6
	jsr	_LVOOpenDevice(a6)
	tst.b	d0
	bne	xit

	move.l	out_hndl(a4),d1
	lea	txt4(pc),a1
	move.l	a1,d2
	moveq	#txt4_end-txt4,d3
	movea.l	dos_base(a4),a6
	jsr	_LVOWrite(a6)

	movea.l	exec_base(a4),a6
	jsr	_LVODisable(a6)

	lea	ciaa_pra,a2
	lea	ciaa_prb,a3
	lea	bss_size(a4),a5
	lea	400(a5),a6
	move.l	a6,d3

.reset	move.b	#$ff,d0		;reset
	bsr.w	sendtoat
	bsr	getkey		;get $aa =selftest complete.
	cmpi.b	#$fe,d0
	beq	.reset

	move.b	#$ed,d0		;setup
	bsr	sendtoat
	move.b	#%00000001,d0	;scroll-lock on
	bsr	sendtoat
	lea	bss_size(a4),a5

.cp	pea	.cp(pc)

getkey:	moveq	#0,d0
	moveq	#1,d2
	moveq	#11,d7
	move.b	#%00000011,(a3)		;set clk & dat

.w_lo	btst	#CIAB_GAMEPORT0,(a2)	;tst left mouse button
	beq	save_file
	btst	#clk_in,(a3)
	bne	.w_lo
	subq.b	#1,d7
	beq.s	.end
	cmpi.b	#10,d7
	beq.s	.w_hi
	move.b	(a3),d0		;read port
	cmpi.b	#1,d7
	beq.s	.par_bit
	btst	#dat_in,d0	;check parity calc
	beq.s	.no_par
	bchg	#0,d2
.no_par	roxr.b	#3,d0		;shift databit to x
	swap	d0
	roxr.b	#1,d0		;save databyte in hi-word
	swap	d0

.w_hi	btst	#CIAB_GAMEPORT0,(a2)
	beq	save_file
	btst	#clk_in,(a3)
	beq	.w_hi
	bra	.w_lo

.par_bit
	lsr.b	#2,d0
	andi.b	#1,d0
	cmp.b	d0,d2
	beq	.w_hi

	move.b	#$fe,d0
	pea	getkey(pc)
	bra	sendtoat

.end	swap	d0
	bsr	h2a
	move.b	d4,(a5)+	;save databyte
	move.b	d5,(a5)+
	move.b	#$20,(a5)+
	cmpa.l	d3,a5
	bge	save_file

.ew_hi	btst	#CIAB_GAMEPORT0,(a2)
	beq	save_file
	btst	#clk_in,(a3)
	beq	.ew_hi
	bclr	#clk_out,(a3)
	rts

sendtoat:
	move.b	d0,_s_byte(a4)	;save byte
	move.b	#%00000011,(a3)

.at_busy
	btst	#CIAB_GAMEPORT0,(a2)
	beq	save_file
	move.b	(a3),d4
	andi.b	#%00001100,d4
	cmpi.b	#%00001100,d4
	bne	.at_busy

	moveq	#7,d7
	move.b	#%00000010,(a3)	;set clk_out, clr dat_out
	moveq	#1,d2
	bsr.s	.chk_lo		;send 8 bit data

	move.b	d2,d0
	moveq	#0,d7
	bsr.s	.chk_lo		;send parity-bit

	moveq	#3,d0
	moveq	#1,d7
	bsr.s	.chk_lo		;send stop-bit & ex-bit
	bclr	#clk_out,(a3)	;ack.

	moveq	#100,d5		;delay 100us
	bsr	delay

	bsr	getkey		;receive ack.
	cmpi.b	#$fe,d0
	beq	.resend
	rts

.resend	move.b	_s_byte(a4),d0
	bra	sendtoat

.chk_lo	btst	#CIAB_GAMEPORT0,(a2)
	beq	save_file
	btst	#clk_in,(a3)
	bne.s	.chk_lo

	move.b	d0,d1
	ori.b	#%00000010,d1		;set clk_out
	move.b	d1,(a3)

	btst	#dat_out,d1
	beq.s	.over
	bchg	#0,d2
.over	lsr.b	#1,d0
.chk_hi	btst	#CIAB_GAMEPORT0,(a2)
	beq	save_file
	btst	#clk_in,(a3)
	beq.s	.chk_hi
	dbra	d7,.chk_lo
	rts

delay	move.l	ioreq(a4),a1
	move.l	d5,_TV_MICRO(a1)
	moveq	#0,d5
	move.l	d5,_TV_SECS(a1)
	moveq	#TR_ADDREQUEST,d5
	move.w	d5,IO_COMMAND(a1)
	movea.l	exec_base(a4),a6
	move.l	d0,-(sp)
	jsr	_LVODoIO(a6)
	tst.l	d0
	bne	save_file
	move.l	(sp)+,d0
	rts

save_file
	move.b	#%00000011,(a3)
	clr.b	ciaa_ddrb
	movea.l	exec_base(a4),a6
	jsr	_LVOEnable(a6)

	move.l	dos_base(a4),a6
	move.l	#MODE_NEWFILE,d2
	move.l	arg_ptr(a4),d1
	jsr	_LVOOpen(a6)
	move.l	d0,d6
	beq	no_file
	move.l	d0,d1
	move.l	#buffer,d2
	move.l	a5,d3
	sub.l	d2,d3
	jsr	_LVOWrite(a6)
	move.l	d6,d1
	jsr	_LVOClose(a6)

	move.l	out_hndl(a4),d1
	lea	txt1(pc),a1
	move.l	a1,d2
	moveq	#txt1_end-txt1,d3
	jsr	_LVOWrite(a6)

p_file	move.l	out_hndl(a4),d1
	move.l	arg_ptr(a4),d2
	move.l	arg_size(a4),d3
	jsr	_LVOWrite(a6)

;=====Free resources (parallel port) and exit=====
; Now free the hardware for someone else to use
xit	move.l	out_hndl(a4),d1
	lea	txt_cr(pc),a0
	move.l	a0,d2
	moveq	#txt_cr_end-txt_cr,d3
	move.l	dos_base(a4),a6
	jsr	_LVOWrite(a6)

	move.l	ioreq(a4),a1
	movea.l	exec_base(a4),a6
	jsr	_LVOCloseDevice(a6)
free6	move.l	ioreq(a4),-(sp)
	jsr	_DeleteExtIO
free5	move.l	msgport(a4),-(sp)
	jsr	_DeletePort

free3	moveq	#MR_PARALLELBITS,d0	;---Free MR_PARALLELBITS
	movea.l	Misc_Base(a4),a6
	jsr	MR_FreeMiscResource(a6)

free2	moveq	#MR_PARALLELPORT,d0	;---Free MR_PARALLELPORT
	movea.l	Misc_Base(a4),a6
	jsr	MR_FreeMiscResource(a6)

free1	move.l	dos_base(a4),a1
	move.l	exec_base(a4),a6
	jsr	_LVOCloseLibrary(a6)
free0	moveq	#0,d0
	move.l	__usp(a4),a7
	rts

no_file	move.l	out_hndl(a4),d1
	lea	txt2(pc),a1
	move.l	a1,d2
	moveq	#txt2_end-txt2,d3
	pea	p_file(pc)
	jmp	_LVOWrite(a6)

no_arg	move.l	out_hndl(a4),d1
	lea	txt3(pc),a1
	move.l	a1,d2
	moveq	#txt3_end-txt3,d3
	pea	free0(pc)
	jmp	_LVOWrite(a6)

;=================================================
h2a	moveq	#1,d6
	move.w	d0,d2
.conv	andi.b	#$f,d0
	addi.b	#$30,d0
	cmpi.b	#$3a,d0
	bcs.s	.digit
	addq.b	#7,d0

.digit	dbra	d6,.next
	move.b	d0,d4
	rts

.next	move.b	d0,d5
	move.w	d2,d0
	lsr.b	#4,d0
	bra.s	.conv

Name	dc.b	'kb-scan',0
T_NAME	TIMERNAME
M_NAME	MISCNAME
CA_NAME	CIAANAME
D_NAME	DOSNAME
txt	dc.b	$a,'	AT-keyboard scancode captor v0.01ß',$a,0
txt_end
txt1	dc.b	$a,'	File saved as "',0
txt1_end
txt2	dc.b	$a,'	Unable to create "',0
txt2_end
txt3	dc.b	$a,'	Error. No file specified.',$a
	dc.b	'	Usage: kb-scan [capture file]',$a,0
txt3_end
txt4	dc.b	'	Press left mousebutton to quit.',$a,0
txt4_end
txt_cr	dc.b	'".',$a,0
txt_cr_end

	section	storage,bss_p

data_zone
	ds.b	bss_size
buffer	ds.b	404
_SysBase	equ	data_zone+exec_base
_DOSBase	equ	data_zone+dos_base
