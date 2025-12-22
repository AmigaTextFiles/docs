
;************************************
;******** MEMORYCARD READER *********
;************************************
;*** hardware design and AVR code ***
;********* by Shin of LKR ***********
;************************************


.include "1200def.inc"


.def	tmp=r16
.def	tmp2=r17
.def	ack=r18
.def	zero=r19
.def	flags=r20
.def	a_byte=r21
.def	count=r22
.def	c_out=r23
.def	c_in=r24
.def	count2=r25
.def	c_cmd=r26

;flags
.equ	ba_got	=0
.equ	ba_sent	=1
.equ	a_got	=1<<ba_got
.equ	a_sent	=1<<ba_sent


.equ	bcard_ack	=2	; iz
.equ	bcard_dat	=0	; iz
.equ	bcard_sel	=3	; oz
.equ	bcard_clk	=4	; oz
.equ	bcard_cmd	=5	; oz
.equ	card_ack	=1<<bcard_ack
.equ	card_dat	=1<<bcard_dat
.equ	card_sel	=1<<bcard_sel
.equ	card_clk	=1<<bcard_clk
.equ	card_cmd	=1<<bcard_cmd

.equ	bamy_clk	=4	; oz
.equ	amy_clk	=1<<bamy_clk

;----------------------------------
.macro	W_CLK0
loop:	sbic	PINB,bamy_clk
	rjmp	loop
.endmacro
;----------------------------------
.macro	W_CLK1
loop:	sbis	PINB,bamy_clk
	rjmp	loop
.endmacro
;*********************************


reset:	rjmp	main
	ser	ack
	reti
	reti

sw0:	out	TCNT0,zero
sw0l:	in	tmp,TCNT0
	cpi	tmp,30
	breq	sw0e
	sbic	PINB,bamy_clk
	rjmp	sw0l
sw0e:	ret	

sw1:	out	TCNT0,zero
sw1l:	in	tmp,TCNT0
	cpi	tmp,30
	breq	sw1e
	sbic	PINB,bamy_clk
	rjmp	sw1l
sw1e:	ret	


main:
; init	
ch_int:
	clr	zero
	out	DDRD,zero
	out	DDRB,zero
	out	PORTD,zero
	out	PORTB,zero

	cli
	out	GIMSK,zero
	out	MCUCR,zero	;!
	ldi	tmp,3
	out	MCUCR,tmp
	ldi	tmp,1<<6
	out	GIMSK,tmp
	sei

loop:	
	out	WDTCR,zero

	out	DDRB,zero
	W_CLK0

;-
	ldi	tmp,0x0E
	out	WDTCR,tmp

	ldi	tmp,0x0F
	out	DDRB,tmp
	W_CLK1
	out	DDRB,zero
	W_CLK0
	in	a_byte,PINB
	andi	a_byte,0x0F
	swap	a_byte
	W_CLK1
	W_CLK0
	in	tmp,PINB
	andi	tmp,0x0F
	or	a_byte,tmp
	W_CLK1
	out	DDRB,zero
;--
	wdr

	cpi	a_byte,'W'
	breq	write
	cpi	a_byte,'R'
	breq	read
	cpi	a_byte,'I'
	breq	info
	rjmp	loop

sabort:	ldi	a_byte,0xA5
s_send:	rcall	a_send
	rjmp	loop
info:	ldi	a_byte,'S'
	rjmp	s_send

;-----------
precard:
	ldi	a_byte,'A'
	rcall	a_send
	rcall	a_get
	mov	r0,a_byte
	rcall	a_get
	mov	r1,a_byte

	sbi	DDRD,bcard_sel
	ldi	tmp,100
r_delay1:	dec	tmp
	brne	r_delay1

	ser	ack
	ldi	c_out,0x81
	rcall	card_io

	mov	c_out,c_cmd
	rcall	card_io
	ldi	c_out,0
	rcall	card_io
	cpi	c_in,'Z'
	brne	abort
	ldi	c_out,0
	rcall	card_io
	cpi	c_in,']'
	brne	abort

	mov	c_out,r0
	rcall	card_io
	mov	c_out,r1
	rcall	card_io
	
	ret

;-----------
write:	ldi	c_cmd,'W'
	rcall	precard
	ldi	a_byte,'o'
	rcall	a_send

	eor	r0,r1
	ldi	count2,128
w_l:	rcall	a_get
	eor	r0,a_byte
	mov	c_out,a_byte
	rcall	card_io
	dec	count2
	brne	w_l
	mov	c_out,r0	; xor flag
	rcall	card_io

	ldi	c_out,0
	rcall	card_io
	cpi	c_in,'\'
	brne	abort

	ldi	c_out,0
	rcall	card_io
	cpi	c_in,']'
	brne	abort

	rjmp	card_f

;--
abort:	rcall	b_delay
	rjmp	sabort

;-----------
read:	ldi	c_cmd,'R'
	rcall	precard


	ldi	c_out,0
	rcall	card_io
	ldi	c_out,0
	rcall	card_io
	cpi	c_in,']'
	brne	abort

	ldi	c_out,0
	rcall	card_io
	cp	c_in,r0
	brne	abort
	ldi	c_out,0
	rcall	card_io
	cp	c_in,r1
	brne	abort

	ldi	a_byte,'o'
	rcall	a_send

	ldi	count2,129
read_l:	ldi	c_out,0x00
	rcall	card_io
	mov	a_byte,c_in
	rcall	a_send
	dec	count2
	brne	read_l
	
card_f:	ldi	c_out,0x00
	rcall	card_io
	cpi	c_in,'G'
	brne	abort
	ldi	a_byte,'E'
	rcall	a_send

	rcall	b_delay
	rjmp	loop

b_delay:	out	DDRD,zero
	out	WDTCR,zero
	ldi	tmp,5
	out	TCCR0,tmp
	out	TCNT0,zero

b_d_l:	in	tmp,TCNT0
	cpi	tmp,100
	brne	b_d_l
	out	TCCR0,zero
	ret

;*********************
;******* amiga side 
;*********************
a_get:
;	    7654  3210
;dat:  A zzzzzzz****xx****xxzz
;dat:  D zzzzzz0zzzzzzzzzzzzz
;clk:  A -----__----__----__--

	out	DDRB,zero
	W_CLK0
	ldi	tmp,0x0F
	out	DDRB,tmp
	W_CLK1
	out	DDRB,zero
	W_CLK0
	in	a_byte,PINB
	andi	a_byte,0x0F
	swap	a_byte
	W_CLK1
	W_CLK0
	in	tmp,PINB
	andi	tmp,0x0F
	or	a_byte,tmp
	W_CLK1
	out	DDRB,zero
	ret

a_send:
;	    7654  3210
;dat:  A zzzzzzzzzzzzzzzzzzzzz
;dat:  D zzzzzz0xxxx**xxxx**zz
;clk:  A -----__----__----__--

	out	DDRB,zero
	ser	tmp
	eor	a_byte,tmp
	W_CLK0
	ldi	tmp,0x0F
	out	DDRB,tmp
	W_CLK1
	mov	tmp,a_byte
	swap	tmp
	andi	tmp,0x0F
	out	DDRB,tmp
	W_CLK0
	W_CLK1
	mov	tmp,a_byte
	andi	tmp,0x0F
	out	DDRB,tmp
	W_CLK0
	W_CLK1
	out	DDRB,zero
	ret



	
;+++++++++++ CARD SIDE I/O SUBPROGRAM ++++++++++++++
; 8mhz = 16+16

;      ____                                                                   
; SEL-     |__________________________________________________________________
;      ______   _   _   _   _   _   _   _   __________________   _   _   _   _
; CLK        |_| |_| |_| |_| |_| |_| |_| |_|                  |_| |_| |_| |_| 
;      __________                                                  ___        
; CMD            |________________________________________________|   |_______
;                                                             ____            
; DAT  -----XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    |___________
;                                                                             
; ACK- ----------------------------------------------|___|--------------------

;.equ	bcard_ack	=2	; iz
;.equ	bcard_dat	=0	; iz
;.equ	bcard_sel	=3	; oz
;.equ	bcard_clk	=4	; oz
;.equ	bcard_cmd	=5	; oz

card_io:
	ldi	tmp,5
	out	TCCR0,tmp
	out	TCNT0,zero
c_io_w:
	in	tmp,TCNT0
	cpi	tmp,30
	breq	c_w_skip
	tst	ack
	breq	c_io_w
c_w_skip:	clr	ack

	ldi	count,8
c_io_l:	ldi	tmp,card_sel|card_clk	;1
	asr	c_out		;1
	brcs	c_io_n1		;1
	ori	tmp,card_cmd	;1
c_io_n1:	out	DDRD,tmp		;1

	andi	tmp,~card_clk	;1
	rcall	s_delay		;7
	rcall	s_delay
	out	DDRD,tmp		;1

	nop
	nop
	nop
	nop
	lsr	c_in		;1
	sbic	PIND,bcard_dat	;1
	ori	c_in,128		;1
	nop			;1
	dec	count		;1
	brne	c_io_l		;2

s_delay:	ret

