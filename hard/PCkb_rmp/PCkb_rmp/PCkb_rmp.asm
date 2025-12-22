; source code for PC keyboard adapter with hardware remapping features
; written for mcs51 family of microcontrollers.
; requires at least 2Kb of program ROM & at least 128b of internal scratchpad RAM
; uses both timers & both interrupts.

; look at scheme(s) for details

; use AS31 assembler (from aminet)

; $VER: pc kbd controller (c) LVD, ver 1.2

;						[c]  Vadik Akimoff, 2:5022/115.37
;					      -------------------------------------
;							lordvader@newmail.ru




;	-=-=-=-=-=-=-=-=-=-=-=
;	    some constants
;	=-=-=-=-=-=-=-=-=-=-=-

	;timer1 const for waiting response (wait 47660*3 cycles)
	.equ	R_const_h,	0x45	; -47660 = $45D4
	.equ	R_const_l,	0xD4

	;I2C device select constants
	.equ	ChipWr,		0xA0	;dev code 1010, hardware addr 000, write operation
	.equ	ChipRd,		0xA1	;dev code 1010, hardware addr 000, read operation

	.equ	Num_to_setup,	6	;number of pause key presses needed to switch to setup mode


;	-=-=-=-=-=-=-=-=-
;	    registers
;	=-=-=-=-=-=-=-=-=

;regs of set 0:
;	r0,r2,r3,r4 - for pc_kbd int routines
;	r1,r5,r6,r7 - for main loop & amy_kbd sync int routines

	;definitions for direct access to regs of set 0:
	.equ	reg0,	0
	.equ	reg1,	1
	.equ	reg2,	2
	.equ	reg3,	3
	.equ	reg4,	4
	.equ	reg5,	5
	.equ	reg6,	6
	.equ	reg7,	7

;regs from other sets are used as memory

;dptr now is only used in pc routines

;B now is only used in I2C comm routines, make sure no conflicts between ints & configurer


;	-=-=-=-=-=-=-=-=-=-=-
;	    hardware pins
;	=-=-=-=-=-=-=-=-=-=-=

	.equ	PCdata,		0xB5	;P3.5
	.equ	PCklk,		0xB2	;P3.2	PCklk must be /INT0

	.equ	AMYdata,	0xB3	;P3.3	AMYdata must be /INT1
	.equ	AMYklk,		0xB0	;P3.0
	.equ	AMYres,		0xB1	;P3.1

	.equ	AMYinit,	0xB4	;P3.4	pull to GND if working in parallel with main kbd

	.equ	SCL,		0x96	;P1.6   EEPROM communication pins
	.equ	SDA,		0x97	;P1.7


;	-=-=-=-=-=-=-=-=-=-=-=-=-=
;	    RAM tables & areas
;	=-=-=-=-=-=-=-=-=-=-=-=-=-
					;tables for remap search
	.equ	RMP_y,		0x30	;byte remap table: scancodes (size: <=32 bytes)
	.equ	RMP_i,		0x58	;bit remap table: $E0 modifiers (size: <=4 bytes)
	.equ	RMP_size,	32	;size of remap table

	.equ	Queue_org,	0x50	;buffer queue from pckbd int routines
	.equ	Queue_size,	8	;to amykbd mainloop (size: 4 bytes)

	.equ	Stack,		0x68	;stack beginning (size: 24 bytes currently, up to $7F)


;	-=-=-=-=-=-=-=-=-=-=-
;	    RAM variables
;	=-=-=-=-=-=-=-=-=-=-=

	.equ	TC_byte,	0x08	;received byte
	.equ	TC_lastsent,	0x09	;last sent byte

	.equ	PS_last,	0x0A	;last press scancode received
	.equ	PS_skipcount,	0x0B	;skip counter (skipping pause sequence etc.)

	.equ	Q_in,		0x0C	;ptrs & ctr for queue of
	.equ	Q_out,		0x0D	;amiga scancodes
	.equ	Q_num,		0x0E

	.equ	STP_counter,	0x0F	;counts pause presses fro entering setup mode

	.equ	STP_pcbyte,	0x10	;pressed key bytes for setup
	.equ	STP_amybyte,	0x11

	.equ	PrS_temp,	0x12	;temp cell for PrtStr

	.equ	STP_cellnum,	0x13	;curr cell in EEPROM

	.equ	STP_b0,		0x14	;buffer for setupper
	.equ	STP_b1,		0x15
	.equ	STP_b2,		0x16
	.equ	STP_b3,		0x17

;	-=-=-=-=-=-=
;	    bits
;	=-=-=-=-=-=-

	.equ	TC_mode,	0x00	;tranceiver mode (0 - receive, 1 - send)
	.equ	TC_error,	0x01	;error during sending or receiving (1 - error)

	.equ	PS_setLED,	0x02	;change led status at 0xFA (if 0xFA is response to 0xED)
	.equ	PS_capslock,	0x03	;actual capslock status	(1 - turned on)
	.equ	PS_E0,		0x04	;if we've received 0xE0 modifier
	.equ	PS_release,	0x05	;if we've received 0xF0 - release
	.equ	PS_last_E0,	0x06	;last press scancode received E0 flag

	.equ	AMY_reset,	0x07	;ctrl-ramiga-lamiga pressed simultaneously

	.equ	AMY_ctrl,	0x08	;tracking of some keys
	.equ	AMY_lamiga,	0x09
	.equ	AMY_ramiga,	0x0A

	.equ	TC_freeze,	0x0B	;if we froze pckbd

	.equ	AMY_gotresp,	0x0C	;indicating we've got response on AMYdata line
	.equ	AMY_resync,	0x0D	;indicating we've had to resync

	.equ	I2C_absent,	0x0E	;1 - no or bad I2C device, no operations with it

	.equ	RMP_empty,	0x0F	;1 - EEPROM empty (nothing to remap)

	.equ	PS_disable,	0x10	;1 - disable some transcoding funcs (for setup)

	.equ	PS_sync,	0x11	;set when press scancode come (for setup)

	.equ	STP_E0,		0x12	;$E0 modifier for setup

	.equ	RA_echo,	0x12	;echo bit for kickin' keyboard

;	-=-=-=-=-=-=-=-=-=-=-=-=-=-
;	    interrupts routines
;	=-=-=-=-=-=-=-=-=-=-=-=-=-=

		.org	0		;RESET vector
		ajmp	PowerUp

		.org	0x03		;INT0 vector
		push	PSW		;2
		jb	TC_mode,I0_send	;2	if sending
		sjmp	I0_receive	;2	else receiving

		.org	0x0b		;TIMER0 vector
		ajmp	irq_TMR0

		.org	0x13		;INT1 vector

		setb	AMY_gotresp	;we're here - GOT RESPONSE !!!!!

		anl	TCON,#0x3F	;TF1=TR1=0

		clr	EX1		;disable further interrupts

		reti			;main prog should wait for AMYdata=1

		.org	0x1b		;TIMER1 vector
		ajmp	irq_TMR1

		.org	0x23		;UART vector
		reti

I0_receive:	;6us already spent
		mov	C,PCdata	;1	save databit (at 7th us)

		setb	TR0		;1	start timer0 for timeouting

		xch	A,r2		;1	store bit in 2-byte shift reg (11 bits total)
		rlc	A		;1
		xch	A,r3		;1
		xch	A,r2		;1	at least, ACC is restored

		djnz	r4,I0_end	;2	if not end

	;if all received - start thinking :)

		clr	PCklk	;handshake/freeze further activity

		push	ACC	;save accumulator

		anl	TCON,#0xCD	;turn off tim0, clr int0 request
		clr	A
		mov	TL0,A
		mov	TH0,A

		clr	EX0
		acall	I0_simintend	;allow other ints to occur

	;first of all check errs - startbit must be 0, stopbit must be 1
	;parity must be a complement of P bit in PSW

		clr	TC_error

	;	clr	A		;ACC already cleared

		xch	A,r3		;r3 now contains 0
		rrc	A
		jnc	I0_rec_error	;test last stopbit
		xch	A,r2
		rrc	A
		mov	F0,C	;F0 is a general purpose flag in PSW - save there received parity
		xch	A,r2

		mov	r4,#8
I0_rec_read8bits:			;repair received byte to r3
		rrc	A
		xch	A,r3
		rlc	A
		xch	A,r3
		xch	A,r2		

		djnz	r4,I0_rec_read8bits

		mov	TC_byte,r3	;save received byte

		rrc	A
		jc	I0_rec_error	;test first startbit

		mov	A,r3
		mov	A,PSW			;get calculated parity
		swap	A
		rl	A			;parity bit in position of F0 bit
		xrl	A,PSW			;xor parity with F0 (received parity)
		jb	ACC.5,I0_rec_noerror	;should be 1 (odd & even parities)
I0_rec_error:
		setb	TC_error
I0_rec_noerror:

		acall	Receive_Action	;mustnot release PCklk!

I0_preend:
		mov	r4,#11		;restore receive bitcounter

		pop	ACC

		jb	TC_freeze,I0_norelease	;if we're frozen
		setb	PCklk	;release PCklk
I0_norelease:
		pop	PSW
		clr	IE0
		setb	EX0
		ret
I0_end:
		pop	PSW		;2
I0_simintend:
		reti			;2   summary 18us/receive, 17us/send



I0_send:	;4us already spent

		xch	A,r2		;1
		rrc	A		;1
		mov	PCdata,C	;2	set databit at 8th us
		xch	A,r3		;1
		xch	A,r2		;1	restore ACC

		setb	TR0		;1

		djnz	r4,I0_end	;2

		clr	PCklk	;handshake/freeze further activity

		;jb	PCdata,TC_snd_error	;because too slow

		push	ACC	;then save accumulator

		anl	TCON,#0xCD	;turn off tim0, clr int0 request
		clr	A
		mov	TL0,A
		mov	TH0,A

		clr	EX0
		acall	I0_simintend

		clr	TC_error	;assume no error detection here yet
I0_snd_noerror:
		acall	Send_Action

		sjmp	I0_preend






irq_TMR0:	;we are here - means PCklk timeout (not synced)
		;break transfer & call (Send|Receive)_Action with error flag
		push	PSW
		push	ACC

		clr	PCklk	;pulldown PCklk

		anl	TCON,#0xCD	;turn off tim0, clr int0 request
		clr	A
		mov	TL0,A
		mov	TH0,A

		clr	EX0
		acall	I0_simintend

		setb	TC_error	;set error flag

		jnb	TC_mode,I0_rec_noerror	;then continue
		sjmp	I0_snd_noerror



irq_TMR1:
		djnz	r1,T1_end
;if we're here - means out of sync

		setb	AMY_resync	;we've really out of sync

		clr	AMYdata		;clock out 1's (low level)

		mov	r1,#9
T1_w0:		djnz	r1,T1_w0

		clr	AMYklk		;after 20us send clk falling edge

		mov	r1,#9
T1_w1:		djnz	r1,T1_w1

		setb	AMYklk		;clk rising edge

		mov	r1,#9
T1_w2:		djnz	r1,T1_w2

		setb	AMYdata		;release AMYdata for possible resp

		mov	r1,#3
T1_end:
		clr	TR1		;stop timer
		mov	TH1,#R_const_h	;reload timer
		mov	TL1,#R_const_l
		setb	TR1		;start timer again

		reti












;	-=-=-=-=-=-=-=-=-=-=-=-=
;	    init & main loop
;	=-=-=-=-=-=-=-=-=-=-=-=-

ReStart:	
		mov	P3,#0b11101011		;PCklk = 0, AMYinit = 0
		sjmp	NoAMYinit
PowerUp:
		mov	P3,#0b11111011		;PCklk = 0, AMYinit = 1
NoAMYinit:
		mov	IE,#0b00001011		;ints enabled: int0, tim0, tim1; globally disabled

		mov	P1,#0xFF		;SCL=SDA=1

		clr	A

		mov	PSW,A			;set bank 0 regs

		mov	r0,#0x80		;clear all mem
Clr_mem:
		mov	@r0,A
		djnz	r0,Clr_mem

		mov	SP,#(Stack-1)		;preincrement on pushing, postdecrement on popping

		;hardware configuration
		mov	IP,#0b00000011		;receiving has higher priority
						;on int0,timer0

		mov	TMOD,#0b00010001	;all timers in mode 1 (16bit)

		mov	TCON,#0b00000001	;int0 by front, int1 by level

		mov	Q_in,#Queue_org		;queue
		mov	Q_out,#Queue_org

		setb	PS_last_E0	;E0 00 - impossible scancode

		inc	PS_skipcount	;init skipcounter (not to skip)

		mov	TL0,A		;assume A is still cleared
		mov	TH0,A

	;some I2C init:

		mov	r6,#10		;send some dummy clocks to ensure i2c device released SDA
					;SCL=SDA=1 (see above: P1=0xFF)
pb_i2cdummy:
		clr	SCL
		nop
		setb	SCL
		djnz	r6,pb_i2cdummy

		acall	STP_waitwr	;zero in r6

		jnc	pb_i2cready
pb_i2cfail:
		setb	I2C_absent	;failed to ack: bad or no device,
		setb	RMP_empty	;all operations are forbidden

		sjmp	pb_endi2c
pb_i2cready:				;now address is set to 0, searchtable can be read

		acall	I2C_prepread	;turn device into reading mode

		jc	pb_i2cfail	;if failed unexpectedly -
					;there is just one chance not to fail! :)

		mov	r0,#RMP_y	;start of remap byte table
		mov	r1,#RMP_i	;start of remap bit table
		mov	r2,#0x01	;starting bit in bit remap table
		mov	r3,#0xFF	;ANDing all pckbd bytes here: if still 0xFF - no remap
					;i.e. assume scancode can't be $FF or $E0 $FF
pb_i2cgetall:
		clr	C		;acknowledge every byte
		acall	I2C_rdbyte	;get next byte
		anl	reg3,A		;ANDing
		mov	@r0,A		;store in mem

		acall	I2C_rdbyte
		jnb	ACC.7,pb_i2cnosetbit
		mov	A,@r1
		orl	A,r2
		mov	@r1,A
pb_i2cnosetbit:
		acall	I2C_rdbyte	;just skip 2 bytes
		acall	I2C_rdbyte

		inc	r0		;increment all counters
		mov	A,r2
		rl	A
		mov	r2,A
		jnb	ACC.0,pb_i2cnobitinc
		inc	r1
pb_i2cnobitinc:
		cjne	r0,#(RMP_y+RMP_size),pb_i2cgetall

		cpl	C		;after skipped cjne carry always cleared
		acall	I2C_rdbyte	;no ack - release bus

		cjne	r3,#0xFF,pb_i2cnoempty
		setb	RMP_empty
pb_i2cnoempty:

pb_endi2c:
		mov	A,#0xFF		;reset code for PC kbd
		acall	RA_normsend	;it will prepare our byte for sending to PC kbd
					;also will clear PCdata & set TC_mode

		mov	r4,#11		;init bitcounter

		setb	EA		;enable ints globally

		setb	PCklk	;release kbd
		;here pckbd should start operating interrupts-driven only...



		;now sync up with amykbd

		jnb	AMYinit,Main	;AMYinit pulled to GND - no powerup resync procedure
Amykbd_poweron:
		mov	TH1,#R_const_h	;preload timer
		mov	TL1,#R_const_l
		mov	r1,#3		;count 3 ints

		setb	TR1		;start timer!

		setb	EX1		;enable waiting for response
Wait_pwon_sync:
		jnb	AMY_gotresp,Wait_pwon_sync	;waitin' sync

		mov	r7,#0xFD		;initiate powerup keystream
		acall	SendByte		;send r7 to Ammy

		mov	r7,#0xFE		;terminate powerup keystream
		acall	SendByte








Main:

		mov	STP_b0,#0		;wait ~15min, then restart
mainwait:
		clr	A			;wait ~3.5s, then send echo ($EE) to kbd
		mov	r5,A
		mov	r6,A
		mov	r7,#5
mainloop:
		jnb	AMY_reset,M_chkqueue	;ctrl-lamiga-ramiga pressed?

		;reset Amiga
		clr	EX1
		clr	TR1

		setb	AMYdata

		clr	AMYklk		;pulldown klk & reset
		clr	AMYres

		clr	A		;wait approx .5 sec
		mov	r6,A
		mov	r7,A
		mov	r1,#4
M_reswait:
		djnz	r7,M_reswait
		djnz	r6,M_reswait
		djnz	r1,M_reswait


M_relwait:	jb	AMY_reset,M_relwait	;wait until release

		setb	AMYres			;release reset
		setb	AMYklk

		sjmp	Amykbd_poweron		;go for resyncing & so on...

M_chkqueue:
		mov	A,Q_num			;is there byte in queue?
		jz	M_chkstp

		mov	r1,Q_out	;take off one byte from queue
		mov	a,@r1
		mov	r7,a
		mov	a,r1
		inc	a
		anl	a,#(Queue_size-1)
		orl	a,#Queue_org
		mov	Q_out,a
		dec	Q_num

		jnb	TC_freeze,M_nofr	;if frozen, warm up it!

		clr	TC_freeze	;no more cold
		setb	PCklk		;release pckbd
M_nofr:

		acall	SendByte

		sjmp	Main

M_chkstp:
		mov	A,STP_counter
		add	A,#-Num_to_setup
		jc	M_setup			;at least Num_to_setup presses to enter setup mode

		djnz	r5,mainloop
		djnz	r6,mainloop
		djnz	r7,mainloop

		jb	TR0,Main		;if receiving/transmitting - no breaking

		clr	EX0
		clr	PCklk
		setb	PCdata
		mov	r7,#60			;approx. 120us
Kick_wait:	djnz	r7,Kick_wait

		mov	A,#0xEE			;send echo ($EE) char
		acall	RA_normsend
		mov	r4,#11
		clr	IE0
		setb	EX0
		clr	RA_echo
		setb	PCklk

		mov	r6,#30		;wait for echo ($EE) for ~30ms
		mov	r7,#0
Kick_echo:
		jb	RA_echo,Kick_OK	;echo - ok, continue
		djnz	r7,Kick_echo
		djnz	r6,Kick_echo
		ajmp	ReStart		;no echo - restart the f#cked keyboard!!
Kick_OK:
		djnz	STP_b0,mainwait	;after ~15min restart anyway
		ajmp	ReStart



















M_setup:
	;interactive setupper starts here

		setb	PS_disable

		mov	r7,#0xE2		;release caps lock
		acall	SendByte

		clr	A
		mov	r6,A
		mov	r7,A
STP_iniwait:
		djnz	r7,STP_iniwait
		djnz	r6,STP_iniwait

		jnb	I2C_absent,STP_i2chere
STP_i2cerr:
		mov	r5,#(MSG_noi2c-MSGbase)	;no I2C -
		acall	PrtStr			;print message &
		ajmp	ReStart			;restart controller

STP_i2chere:
		mov	r5,#(MSG_hello-MSGbase)
		acall	PrtStr
STP_loop:
		mov	r5,#(MSG_cell0-MSGbase)
		acall	PrtStr

		mov	A,STP_cellnum
		acall	PrtHex

		mov	r5,#(MSG_cell1-MSGbase)
		acall	PrtStr

		mov	A,STP_cellnum
		rl	A
		rl	A
		mov	r6,A

		acall	STP_waitwr
		jc	STP_i2cerr

		acall	I2C_prepread
		jc	STP_i2cerr

		mov	r1,#STP_b0
		mov	r5,#0xFF
STP_fillbuff:
		clr	C
		acall	I2C_rdbyte
		mov	@r1,A
		anl	reg5,A
		inc	r1
		cjne	r1,#(STP_b3+1),STP_fillbuff
		cpl	C
		acall	I2C_rdbyte

		cjne	r5,#0xFF,STP_notempty

		mov	r5,#(MSG_empty-MSGbase)
		acall	PrtStr
		sjmp	STP_cend

STP_notempty:
		mov	A,STP_b1
		jb	ACC.7,STP_isE0

		mov	PrS_temp,#0x40
		mov	r5,#3
		acall	PrtRep

		sjmp	STP_afterE0
STP_isE0:
		mov	r5,#(MSG_E0-MSGbase)
		acall	PrtStr

STP_afterE0:
		mov	A,STP_b0
		acall	PrtHex

		mov	r5,#(MSG_cell2-MSGbase)
		acall	PrtStr

		mov	A,STP_b1
		anl	A,#0x7F
		acall	PrtHex

		mov	r7,#0x40
		acall	PrtSym

		mov	A,STP_b2
		jb	ACC.7,STP_cend
		acall	PrtHex
		mov	r7,#0x40
		acall	PrtSym

		mov	A,STP_b3
		jb	ACC.7,STP_cend
		acall	PrtHex
STP_cend:
		mov	r7,#0x44
		acall	PrtSym

STP_startwait:
		clr	PS_sync
STP_waitkey:
		jnb	PS_sync,STP_waitkey

		mov	A,STP_amybyte

		mov	r1,#STP_cellnum

		cjne	A,#0x4C,STP_nocurup
						;dec pointer
		dec	@r1
		mov	A,@r1
		add	A,#-(RMP_size)
		jnc	STP_goloop
		mov	@r1,#(RMP_size-1)
		ajmp	STP_loop
STP_nocurup:
		cjne	A,#0x4D,STP_nocurdn
						;inc pointer
		inc	@r1
		mov	A,@r1
		add	A,#-(RMP_size)
		jnc	STP_goloop
		mov	@r1,#0
STP_goloop:
		ajmp	STP_loop
STP_nocurdn:
		cjne	A,#0x22,STP_nokeyD
						;done - restart controller
		ajmp	ReStart
STP_nokeyD:
		cjne	A,#0x28,STP_nokeyL
						;clear current cell
		mov	A,@r1
		rl	A
		rl	A
		mov	r6,A
		mov	r5,#4
STP_clrcell:
		acall	STP_waitwr
		jc	STP_i2cerr_long

		mov	A,#0xFF
		acall	I2C_wrbyte
		jc	STP_i2cerr_long

		inc	r6
		djnz	r5,STP_clrcell

		ajmp	STP_loop
STP_nokeyL:
		cjne	A,#0x12,STP_nokeyE
						;clear all cells
		mov	r6,#0
STP_clrall:
		acall	STP_waitwr
		jc	STP_i2cerr_long

		mov	A,#0xFF
		acall	I2C_wrbyte
		jc	STP_i2cerr_long

		inc	r6
		cjne	r6,#(RMP_size*4),STP_clrall

		ajmp	STP_loop
STP_i2cerr_long:
		ajmp	STP_i2cerr

STP_nokeyE:
		cjne	A,#0x33,STP_startwait	;STP_nokeyC

						;gen new data for current cell
		mov	r5,#(MSG_prpc-MSGbase)
		acall	PrtStr

STP_startwaitpc:
		clr	PS_sync
STP_waitpc:
		jnb	PS_sync,STP_waitpc

		mov	A,STP_amybyte
		jb	ACC.7,STP_startwaitpc	;just press scancodes allowed

		mov	C,STP_E0
		mov	F0,C			;store E0 modifier

		jnc	STP_wpcnoE0
		mov	r5,#(MSG_E0-MSGbase)
		acall	PrtStr
STP_wpcnoE0:

		mov	A,STP_pcbyte
		mov	STP_b0,A
		acall	PrtHex

		mov	r7,#0x44
		acall	PrtSym

		mov	r5,#(MSG_prammy-MSGbase)
		acall	PrtStr

		mov	r1,#STP_b1

		mov	A,#0xFF
		mov	@r1,A
		mov	STP_b2,A
		mov	STP_b3,A

STP_startwaitammy:
		clr	PS_sync
STP_waitammy:
		jnb	PS_sync,STP_waitammy

		mov	A,STP_amybyte
		jb	ACC.7,STP_waend

		mov	@r1,A
		inc	r1

		push	reg1
		acall	PrtHex
		mov	r7,#0x40
		acall	PrtSym
		pop	reg1

		cjne	r1,#(STP_b3+1),STP_startwaitammy
STP_waend:
		mov	r7,#0x44
		acall	PrtSym		

		mov	A,STP_b1
		mov	C,F0
		mov	ACC.7,C
		mov	STP_b1,A


		mov	r1,#STP_b0

		mov	A,STP_cellnum
		rl	A
		rl	A
		mov	r6,A
STP_wrcell:
		acall	STP_waitwr
		jc	STP_i2cerr_long

		mov	A,@r1
		acall	I2C_wrbyte
		jc	STP_i2cerr_long

		inc	r6
		inc	r1
		cjne	r1,#(STP_b3+1),STP_wrcell

		ajmp	STP_loop






;	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;	    Some routines for setupper
;	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

STP_waitwr:
		mov	r7,#0
STP_wrbl:
		mov	A,r6
		acall	I2C_setaddr
		jnc	STP_wrbc
		djnz	r7,STP_wrbl
STP_wrbc:
		ret
		

PrtRep:
		acall	PrtSym_mod
		djnz	r5,PrtRep
		ret

PrtSym_mod:
		mov	r7,PrS_temp
PrtSym:
		mov	PrS_temp,r7
		acall	SendByte
		mov	A,PrS_temp
		orl	A,#0x80
		ajmp	SendByteACC

PrS_cont:
		jnz	PrS_noend
		ret
PrS_noend:
		jbc	ACC.7,PrS_shift
		mov	PrS_temp,A
		acall	SendByteACC
		mov	A,PrS_temp
		orl	A,#0x80
		mov	r7,A
		sjmp	PrS_prs
PrS_shift:
		mov	PrS_temp,A			;just store ACC there
		mov	r7,#0x60
		acall	SendByte
		mov	r7,PrS_temp
		acall	SendByte
		mov	A,PrS_temp
		orl	A,#0x80
		acall	SendByteACC
		mov	r7,#0xE0
PrS_prs:
		acall	SendByte
PrtStr:
		mov	A,r5
		inc	r5

		movc	A,@A+pc
MSGbase:
		sjmp	PrS_cont
MSG_hello:
		;	"SETUP MODE<enter>"
		.db	0xA1,0x92,0x94,0x96,0x99, 0x40, 0xB7,0x98,0xA2,0x92, 0x44
		;	"Change,cLear,Done,Erase all,cursor up/down<enter>"
		.db	0xB3,0x25,0x20,0x36,0x24,0x12, 0x38, 0x33,0xA8,0x12,0x20,0x13, 0x38
		.db	0xA2,0x18,0x36,0x12, 0x38, 0x92,0x13,0x20,0x21,0x12, 0x40
		.db	0x20,0x28,0x28, 0x38, 0x33,0x16,0x13,0x21,0x18,0x13, 0x40
		.db	0x16,0x19,0x3A,0x22,0x18,0x11,0x36,0x44, 0x00

MSG_cell0:
		;	"cell "
		.db	0x33,0x12,0x28,0x28,0x40, 0x00

MSG_cell1:
		;	": "
		.db	0xA9,0x40,0x00

MSG_cell2:
		;	" -> "
		.db	0x40,0x0B,0xB9,0x40, 0x00

MSG_prpc:
		;	"PC key: "
		.db	0x99,0xB3,0x40,0x27,0x12,0x15,0xA9,0x40, 0x00

MSG_prammy:
		;	"AMIGA key(s): "
		.db	0xA0,0xB7,0x97,0xA4,0xA0,0x40,0x27,0x12,0x15,0x89,0x21,0x8A,0xA9,0x40, 0x00

MSG_noi2c:
		;	"NO or BAD i2c device!<enter>"
		.db	0xB6,0x98,0x40,0x18,0x13,0x40,0xB5,0xA0,0xA2,0x40
		.db	0x17,0x02,0x33,0x40,0x22,0x12,0x34,0x17,0x33,0x12,0x81,0x44,0x00

MSG_empty:
		;	"empty"
		.db	0x12,0x37,0x19,0x14,0x15,0x00

MSG_E0:
		;	"e0 "
		.db	0x12,0x0A,0x40,0x00



PrtHex:
		mov	r5,A
		anl	A,#0xF0
		swap	A
		add	A,#(HEX-HEX_1)
		movc	A,@A+pc
HEX_1:
		acall	HEX_2
		mov	A,r5
		anl	A,#0x0F
		add	A,#(HEX-HEX_2)
		movc	A,@A+pc
HEX_2:
		mov	r7,A
		acall	SendByte
		mov	A,r7
		orl	A,#0x80
		mov	r7,A
		ajmp	SendByte

HEX:
		.db	0x0A	;0
		.db	0x01	;1
		.db	0x02	;2
		.db	0x03	;3
		.db	0x04	;4
		.db	0x05	;5
		.db	0x06	;6
		.db	0x07	;7
		.db	0x08	;8
		.db	0x09	;9
		.db	0x20	;A
		.db	0x35	;B
		.db	0x33	;C
		.db	0x22	;D
		.db	0x12	;E
		.db	0x23	;F








;	-=-=-=-=-=-=-=-=-=-=-=-=-
;	    AMMY kbd routines
;	=-=-=-=-=-=-=-=-=-=-=-=-=

SendByteACC:	mov	r7,A
SendByte:	;sends r7 to Ammy
		;saves r5 !!!

		jnb	PS_disable,SB_nopause	;make pause if we're in setup mode
						;else TOO fast -> out of sync
		mov	r1,#20
		mov	r6,#0
SB_pause:
		djnz	r6,SB_pause
		djnz	r1,SB_pause
SB_nopause:

		mov	A,r7
		acall	ClockByte			;clock ACC out, prepare for ack

SB_waitresp:	jb	AMY_reset,SB_reset
		jnb	AMY_gotresp,SB_waitresp

		jb	AMY_resync,SB_resend		;is all ok?
SB_reset:
		ret
SB_resend:
		mov	A,#0xF9				;send 'last scancode bad'
		acall	ClockByte

SB_wrbad:	jb	AMY_reset,SB_reset
		jnb	AMY_gotresp,SB_wrbad

		jb	AMY_resync,SB_resend		;if failed - try again...
		sjmp	SendByte



ClockByte:	;clocks ACC out
		;trashes ACC,r6; reloads r1 - timer overflow int counter

		mov	TH1,#R_const_h	;preload timer (already stopped)
		mov	TL1,#R_const_l

		clr	AMY_gotresp
		clr	AMY_resync


		rl	A	;6-5-4-3-2-1-0-7 bit order
		cpl	A	;1 - low level, 0 - high level


CB_waitdata:	jnb	AMYdata,CB_waitdata	;wait for end of response

		mov	r6,#8	;send 8 bits
CB_bit:
		rlc	A
		mov	AMYdata,C

		mov	r1,#9
CB_w0:		djnz	r1,CB_w0

		clr	AMYklk

		mov	r1,#9
CB_w1:		djnz	r1,CB_w1

		setb	AMYklk

		mov	r1,#7
CB_w2:		djnz	r1,CB_w2

		djnz	r6,CB_bit
		setb	AMYdata

		mov	r1,#3		;count 3 ints

		setb	TR1
		setb	EX1

		ret



;	-=-=-=-=-=-=-=-=-=-=-=-
;	    PC kbd routines
;	=-=-=-=-=-=-=-=-=-=-=-=

Receive_Action:	;after byte receiving

		mov	A,#0xFE
		jb	TC_error,RA_normsend	;if bad byte received, tell kbd to resend byte

		mov	a,TC_byte
		cjne	a,#0xFA,RA_noack

;RA_ack:	;if acknowledge byte received

		jbc	PS_setLED,RA_caps	;jump if bit, then clear
		ret
RA_caps:
		clr	a
		mov	C,PS_capslock
		mov	ACC.2,C

RA_normsend:
		mov	TC_lastsent,a
RA_specsend:
		setb	TC_mode		;1 means send mode

		acall	Prep2Send	;prepare byte for sending

		clr	PCdata		;tell kbd we want to send smth
		ret

RA_noack:
		cjne	a,#0xFE,RA_noresend

;RA_resend:	;resend last byte sent, if kbd asks

		mov	a,TC_lastsent
		sjmp	RA_specsend

RA_noresend:
		cjne	A,#0xEE,RA_noecho
		setb	RA_echo
		ret
RA_noecho:
		cjne	a,#0xAA,RA_transcode
TR_ret:
		ret



RA_transcode:	;transcoder starts here

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		djnz	PS_skipcount,TR_ret
		inc	PS_skipcount		;PS_skipcount=1

		cjne	a,#0xE0,TR_noE0
;TR_E0:					;if we've got 0xE0 modifier
		setb	PS_E0
		ret
TR_noE0:
		cjne	a,#0xF0,TR_norelease
;TR_release:				;if we've got 0xF0 release flag
		setb	PS_release
		ret
TR_norelease:


		cjne	A,#0xE1,TR_nopause	;if we've got 0xE1 - first
						;byte of pause sequence
;TR_pause:	;pause pressed
		mov	PS_skipcount,#(7+1)	;skip next 7 bytes
		inc	STP_counter		;inc pausepress counter
		ret
TR_nopause:
		mov	STP_counter,#0		;clear pausepress counter

		;checking for repeat - only last press scancode can repeat
		cjne	A,PS_last,TR_wrk	;if scancodes differ

		jb	PS_E0,TR_rep1
		jb	PS_last_E0,TR_wrk
		sjmp	TR_rep2
TR_rep1:
		jnb	PS_last_E0,TR_wrk
TR_rep2:
		jb	PS_release,TR_cont1	;if press - just ignore
		ajmp	TR_end			;not enough for relative addressing
TR_cont1:
		setb	PS_last_E0	;else set last scancode to E0 00
		mov	PS_last,#0

TR_wrk:
		jb	PS_release,TR_wrk1

		mov	PS_last,A
		mov	C,PS_E0
		mov	PS_last_E0,C
TR_wrk1:

		jnb	PS_E0,TR_notprtscr	;KILL the f#ucked 1st scancode of PrtScr!!! ($E0 $12)
		cjne	A,#0x12,TR_notprtscr
		ajmp	TR_end
TR_notprtscr:


	;	push	DPL		;dptr still isn't used in main loop
	;	push	DPH

		jb	PS_disable,TR_disbl	;disable - setupmode
		jnb	RMP_empty,TR_remap	;no or empty eeprom - no remap
TR_disbl:
		ajmp	TR_noremap
TR_remap:
		mov	r4,A

		mov	r3,#RMP_y
TR_rmpl:
		mov	r0,reg3
		mov	A,@r0
		cjne	A,reg4,TR_rmpnxt	;compare scancodes

		mov	A,r3			;calc $E0 bit modifier position
		add	A,#-(RMP_y)
		mov	r2,A
		anl	A,#0x07
		inc	A
		xch	A,r2
		rr	A
		rr	A
		rr	A
		anl	A,#0x03
		add	A,#RMP_i
		mov	r0,A
		mov	A,#0x80
TR_rmprotbit:
		rl	A
		djnz	r2,TR_rmprotbit

		anl	A,@r0			;compare $E0 modifiers
		jb	PS_E0,TR_rmpE0tst
		jnz	TR_rmpnxt
		sjmp	TR_dormp
TR_rmpE0tst:
		jz	TR_rmpnxt

TR_dormp:
		mov	A,r3
		add	A,#-(RMP_y)
		rl	A			;calc address in EEPROM
		rl	A
		inc	A
		acall	I2C_setaddr
		jc	TR_rmpmiss
		acall	I2C_prepread
		jc	TR_rmpmiss

	;	clr	C			;get first byte
		acall	I2C_rdbyte
		anl	A,#0x7F			;remove $E0 modifier bit
		cjne	A,#0x7F,TR_rmpnocaps	;check for remapped capslock
		cpl	C
		acall	I2C_rdbyte		;end EEPROM session
		sjmp	TR_caps
TR_rmpnocaps:
		jb	PS_release,TR_rmprel	;press/release cases

		acall	Send2Ammy

		clr	C			;get second byte
		acall	I2C_rdbyte
		jb	ACC.7,TR_rpend
		acall	Send2Ammy

		setb	C			;get third byte
		acall	I2C_rdbyte
		jnb	ACC.7,TR_sendend
		sjmp	TR_popend
TR_rpend:
		setb	C
		acall	I2C_rdbyte		;end EEPROM session
		sjmp	TR_popend

TR_rmprel:
		orl	A,#0x80
		mov	r2,A			;release - reversed byteorder - determine num of bytes
		clr	C
		acall	I2C_rdbyte
		jnb	ACC.7,TR_rmore1

		setb	C			;one byte
		acall	I2C_rdbyte
		mov	A,r2
		sjmp	TR_sendend
TR_rmore1:
		orl	A,#0x80
		mov	r3,A

		setb	C
		acall	I2C_rdbyte
		jb	ACC.7,TR_rnomore2
		orl	A,#0x80
		acall	Send2Ammy
TR_rnomore2:
		mov	A,r3
		acall	Send2Ammy
		mov	A,r2
		sjmp	TR_sendend



TR_rmpnxt:
		inc	r3
		cjne	r3,#(RMP_y+RMP_size),TR_rmpl
TR_rmpmiss:
		mov	A,r4

TR_noremap:
		jnb	ACC.7,TR_lowpart	;look at table only for $00-$7F scancodes
		jb	PS_E0,TR_popend		;no scancodes >$7F for $E0 part
		cjne	A,#0x83,TR_highpart	;only $83 (key F7) for non-$E0 part
		mov	A,#0x56			;amiga F7
		sjmp	TR_aftertable
TR_highpart:
		mov	A,#0xFF
		sjmp	TR_aftertable
TR_lowpart:
		mov	DPTR,#Trans_table

		mov	C,PS_E0
		mov	ACC.7,C

		movc	A,@A+dptr		;probably the main part of all prog =)

TR_aftertable:
		jnb	PS_disable,TR_nosavedsbl	;test setup mode

		jb	PS_sync,TR_popend		;rewrite only if allowed (PS_sync)

		mov	STP_pcbyte,TC_byte		;copy pc scancode
		mov	C,PS_E0
		mov	STP_E0,C

		mov	C,PS_release			;copy amiga scancode
		mov	ACC.7,C
		mov	STP_amybyte,A

		setb	PS_sync				;set sync bit (result ready)

		sjmp	TR_popend
TR_nosavedsbl:


		jb	ACC.7,TR_special	;bit7 means special, i.e.
						;double scancodes, etc.

		cjne	A,#0x7F,TR_nocaps
TR_caps:					;capslock pressed
		jb	PS_release,TR_popend	;if capslock released - nothing

		mov	C,PS_capslock	;get capslock bit

		mov	A,#0x62		;prepare amiga capslock scancode
		mov	ACC.7,C		;if capslock was off - press
					;if capslock was on - release

		cpl	C		;invert capslock state
		mov	PS_capslock,C

		acall	Send2Ammy	;send it to amiga

		mov	A,#0xED		;set LED on pckbd
		setb	PS_setLED
		acall	RA_normsend	;prepare it for sending
		sjmp	TR_popend

TR_nocaps:
		mov	C,PS_release
		mov	ACC.7,C

TR_sendend:
		acall	Send2Ammy	;ACC goes as scancode to Amiga
TR_popend:







	;	pop	DPH
	;	pop	DPL
TR_end:
		clr	PS_release
		clr	PS_E0
		ret

TR_special:
;$FF means no scancode generating, $8x - special

		cjne	A,#0xFF,TR_spec2
		sjmp	TR_popend
TR_spec2:
		mov	dptr,#Dblkeytbl

		add	A,ACC	;double ACC (high bit lost)
		mov	r2,A

		movc	A,@A+dptr
		xch	A,r2
		inc	A
		movc	A,@A+dptr

		jb	PS_release,TR_ds_rel

		xch	A,r2
		acall	Send2Ammy
		mov	A,r2
		sjmp	TR_sendend
TR_ds_rel:
		orl	A,#0x80
		acall	Send2Ammy
		mov	A,r2
		orl	A,#0x80
		sjmp	TR_sendend






Send2Ammy:	;put ACC to in queue for sending to amiga
		;no filtering of multiple keys done!
		;trashes ACC, r0

		cjne	A,#0x63,S2A_noprctrl	;track reset keys
		setb	AMY_ctrl
S2A_noprctrl:	cjne	A,#0xE3,S2A_norlctrl
		clr	AMY_ctrl
S2A_norlctrl:	cjne	A,#0x66,S2A_noprlamiga
		setb	AMY_lamiga
S2A_noprlamiga:	cjne	A,#0xE6,S2A_norllamiga
		clr	AMY_lamiga
S2A_norllamiga:	cjne	A,#0x67,S2A_noprramiga
		setb	AMY_ramiga
S2A_noprramiga:	cjne	A,#0xE7,S2A_norlramiga
		clr	AMY_ramiga
S2A_norlramiga:

		mov	C,AMY_ctrl		;form reset flag
		anl	C,AMY_lamiga
		anl	C,AMY_ramiga
		mov	AMY_reset,C


		;here store amiga scancode in queue
		;!!!!!!!!!!! CURRENTLY NO OVERFLOW FREEZE !!!!!!!!!!

		mov	r0,Q_num			;check for queue overflow
		cjne	r0,#Queue_size,S2A_qustore
		ret
S2A_qustore:
		inc	Q_num
		mov	r0,Q_in
		mov	@r0,A
		mov	A,r0
		inc	A
		anl	A,#(Queue_size-1)
		orl	A,#Queue_org
		mov	Q_in,A
		ret





Send_Action:	;after byte sending

		clr	TC_mode		;1st of all, set mode to RECEIVING!

		ret	;nothing to do here yet :(



Prep2Send:	;input in ACC. result in r2/r3 prepared for I0_send
		;trashes r4

		mov	r2,#0xFF
		mov	r3,#0xFF

		mov	C,P
		cpl	C
		xch	A,r2
		rlc	A
		xch	A,r2

		mov	r4,#8
p2s_loop0:
		rlc	A
		xch	A,r3
		rlc	A
		xch	A,r2
		xch	A,r3

		djnz	r4,p2s_loop0

		ret



;	-=-=-=-=-=-=-=-=-=-=
;	    I2C routines
;	=-=-=-=-=-=-=-=-=-=-

;	All I2C routines intended for at least 400kHz bus (@ 12MHz)

I2C_setaddr:	;sets given (in ACC) address in device
		;sets SDA & SCL to 1's, then creates start condition.
		;leaves bus with SDA=1, SCL=0 ready for clocking byte(s) to write
		; or to create another start condition for read operations
		;carry is set if no acknowledgement received (bus error or device not ready)
		; if no ack in command byte, bus state is SCL=SDA=1
		; can be used for testing readyness of device
		;trashes ACC, B

		;remark: working time if I2C device is not ready is 84 us (including call, @ 12MHz)

		setb	SDA
		setb	SCL

		clr	SDA		;start condition

		clr	SCL

		push	ACC

		mov	A,#ChipWr

		mov	B,#8		;we cannot use regs (r0-r7) because this proc can be called
					;either from PCkbd int routine or from AMYkbd mainloop
i2c_saloop0:
		rlc	A
		mov	SDA,C
		setb	SCL
		nop
		clr	SCL		
		djnz	B,i2c_saloop0

		setb	SDA
		setb	SCL
		mov	C,SDA
		jnc	i2c_sacont	;exit with carry set if no acknowledge
		pop	ACC
		ret
i2c_sacont:
		clr	SCL

		pop	ACC		;send address

	;	mov	B,#8
		setb	B.3	;1 byte saved ;)
i2c_saloop1:
		rlc	A
		mov	SDA,C
		setb	SCL
		nop
		clr	SCL
		djnz	B,i2c_saloop1

		setb	SDA
		setb	SCL
		mov	C,SDA		;read last ack bit in carry
		clr	SCL

		ret


I2C_prepread:	;prepares bus for reading (normally used after I2C_setaddr)
		;creates start condition then sends ÑhipRd byte
		;leaves bus with SCL=0, SDA=1 ready for reading
		;sets carry if no acknowledgement received
		;trashes ACC, B

		setb	SDA
		setb	SCL

		clr	SDA		;start condition

		clr	SCL

		mov	A,#ChipRd

		mov	B,#8
i2c_prloop:
		rlc	A
		mov	SDA,C
		setb	SCL
		nop
		clr	SCL
		djnz	B,i2c_prloop

		setb	SDA
		setb	SCL
		mov	C,SDA
		clr	SCL

		ret


I2C_rdbyte:	;reads byte from bus into ACC
		;normally bus should be prepared by (optionally) I2C_setaddr, then I2C_prepread
		;if carry is 0 - continues reading (make acknowledgement), bus: SCL=0, SDA=1
		;if carry is 1 - discontinues readind (no ack, stop condition), bus: SCL=SDA=1
		;trashes B, saves carry

		push	PSW

		mov	B,#8
i2c_rbloop:
		setb	SCL
		mov	C,SDA
		rlc	A
		clr	SCL
		djnz	B,i2c_rbloop

		pop	PSW
		mov	SDA,C
		setb	SCL		;send acknowledge
		nop
		clr	SCL		

		clr	SDA		;prepare for possible stop condition
		mov	SCL,C		;if carry - release SCL, then stop

		setb	SDA		;release SDA or stop condition
		ret


I2C_wrbyte:	;writes single byte (from ACC) to device, then gives stop condition
		;bus should be prepared by I2C_setaddr
		;carry is set if no ack from device
		;leaves bus in SCL=SDA=1
		;trashes B

		mov	B,#8
i2c_wbloop:
		rlc	A
		mov	SDA,C
		setb	SCL
		nop
		clr	SCL
		djnz	B,i2c_wbloop

		setb	SDA
		setb	SCL
		mov	C,SDA
		clr	SCL

		clr	SDA
		setb	SCL
		setb	SDA		;stop condition

		ret






;	-=-=-=-=-=-=-=-=-=-=-=-=-=
;	    transcoding tables
;	=-=-=-=-=-=-=-=-=-=-=-=-=-

Dblkeytbl:	;table for default double-keys

		.db	0x61,0x4F	;	$80	rshift-cursorleft
		.db	0x61,0x4E	;	$81	rshift-cursorright
		.db	0x61,0x4C	;	$82	rshift-cursorup
		.db	0x61,0x4D	;	$83	rshift-cursordown
		.db	0x66,0x37	;	$84	lamiga-m


Trans_table:	;general table for transcoding

;$FF means no scancode generating, $8x - special, $7F - capslock

;	$80 - RSHIFT-CURSORLEFT
;	$81 - RSHIFT-CURSORRIGHT
;	$82 - RSHIFT-CURSORUP
;	$83 - RSHIFT-CURSORDOWN
;	$84 - LAMIGA-M

;non-E0 scantable starts

;               AMMY    ;        PC
	.db	0xFF	;	$00
	.db	0x58	;	$01	F9
	.db	0xFF	;	$02
	.db	0x54	;	$03	F5
	.db	0x52	;	$04	F3
	.db	0x50	;	$05	F1
	.db	0x51	;	$06	F2
	.db	0x2B	;	$07	F12 -> RIGHT BLANK
	.db	0xFF	;	$08
	.db	0x59	;	$09	F10
	.db	0x57	;	$0A	F8
	.db	0x55	;	$0B	F6
	.db	0x53	;	$0C	F4
	.db	0x42	;	$0D	TAB
	.db	0x00	;	$0E	~ aka '
	.db	0xFF	;	$0F

	.db	0xFF	;	$10
	.db	0x64	;	$11	LALT
	.db	0x60	;	$12	LSHIFT
	.db	0xFF	;	$13
	.db	0x63	;	$14	LCTRL -> CTRL
	.db	0x10	;	$15	Q
	.db	0x01	;	$16	1
	.db	0xFF	;	$17
	.db	0xFF	;	$18
	.db	0xFF	;	$19
	.db	0x31	;	$1A	Z
	.db	0x21	;	$1B	S
	.db	0x20	;	$1C	A
	.db	0x11	;	$1D	W
	.db	0x02	;	$1E	2
	.db	0xFF	;	$1F

	.db	0xFF	;	$20
	.db	0x33	;	$21	C
	.db	0x32	;	$22	X
	.db	0x22	;	$23	D
	.db	0x12	;	$24	E
	.db	0x04	;	$25	4
	.db	0x03	;	$26	3
	.db	0xFF	;	$27
	.db	0xFF	;	$28
	.db	0x40	;	$29	SPACE
	.db	0x34	;	$2A	V
	.db	0x23	;	$2B	F
	.db	0x14	;	$2C	T
	.db	0x13	;	$2D	R
	.db	0x05	;	$2E	5
	.db	0xFF	;	$2F

	.db	0xFF	;	$30
	.db	0x36	;	$31	N
	.db	0x35	;	$32	B
	.db	0x25	;	$33	H
	.db	0x24	;	$34	G
	.db	0x15	;	$35	Y
	.db	0x06	;	$36	6
	.db	0xFF	;	$37
	.db	0xFF	;	$38
	.db	0xFF	;	$39
	.db	0x37	;	$3A	M
	.db	0x26	;	$3B	J
	.db	0x16	;	$3C	U
	.db	0x07	;	$3D	7
	.db	0x08	;	$3E	8
	.db	0xFF	;	$3F

	.db	0xFF	;	$40
	.db	0x38	;	$41	< aka ,
	.db	0x27	;	$42	K
	.db	0x17	;	$43	I
	.db	0x18	;	$44	O
	.db	0x0A	;	$45	0
	.db	0x09	;	$46	9
	.db	0xFF	;	$47
	.db	0xFF	;	$48
	.db	0x39	;	$49	> aka .
	.db	0x3A	;	$4A	/ aka ?
	.db	0x28	;	$4B	L
	.db	0x29	;	$4C	; aka :
	.db	0x19	;	$4D	P
	.db	0x0B	;	$4E	- aka _
	.db	0xFF	;	$4F

	.db	0xFF	;	$50
	.db	0xFF	;	$51
	.db	0x2A	;	$52	" aka '
	.db	0xFF	;	$53
	.db	0x1A	;	$54	[
	.db	0x0C	;	$55	+ aka =
	.db	0xFF	;	$56
	.db	0xFF	;	$57
	.db	0x7F	;	$58	CAPS LOCK
	.db	0x61	;	$59	RSHIFT
	.db	0x44	;	$5A	ENTER
	.db	0x1B	;	$5B	]
	.db	0xFF	;	$5C
	.db	0x0D	;	$5D	\ aka |
	.db	0xFF	;	$5E
	.db	0xFF	;	$5F

	.db	0xFF	;	$60
	.db	0x0D	;	$61	\ aka |   -   same as $5D
	.db	0xFF	;	$62
	.db	0xFF	;	$63
	.db	0xFF	;	$64
	.db	0xFF	;	$65
	.db	0x41	;	$66	BACKSPACE
	.db	0xFF	;	$67
	.db	0xFF	;	$68
	.db	0x1D	;	$69	KEYPAD 1
	.db	0xFF	;	$6A
	.db	0x2D	;	$6B	KEYPAD 4
	.db	0x3D	;	$6C	KEYPAD 7
	.db	0xFF	;	$6D
	.db	0xFF	;	$6E
	.db	0xFF	;	$6F

	.db	0x0F	;	$70	KEYPAD 0
	.db	0x3C	;	$71	KEYPAD .
	.db	0x1E	;	$72	KEYPAD 2
	.db	0x2E	;	$73	KEYPAD 5
	.db	0x2F	;	$74	KEYPAD 6
	.db	0x3E	;	$75	KEYPAD 8
	.db	0x45	;	$76	ESC
	.db	0xFF	;	$77	NUM LOCK -> NOTHING
	.db	0x30	;	$78	F11 -> LEFT BLANK
	.db	0x5E	;	$79	KEYPAD +
	.db	0x1F	;	$7A	KEYPAD 3
	.db	0x4A	;	$7B	KEYPAD -
	.db	0x5D	;	$7C	KEYPAD *
	.db	0x3F	;	$7D	KEYPAD 9
	.db	0x5B	;	$7E	SCROLL LOCK -> KEYPAD )
	.db	0xFF	;	$7F

	;;;db	0x56	;	$83	F7 - handled by prog

;non-E0 scantable ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;E0 scantable starts

;               AMMY    ;        PC
	.db	0xFF	;	$00
	.db	0xFF	;	$01
	.db	0xFF	;	$02
	.db	0xFF	;	$03
	.db	0xFF	;	$04
	.db	0xFF	;	$05
	.db	0xFF	;	$06
	.db	0xFF	;	$07
	.db	0xFF	;	$08
	.db	0xFF	;	$09
	.db	0xFF	;	$0A
	.db	0xFF	;	$0B
	.db	0xFF	;	$0C
	.db	0xFF	;	$0D
	.db	0xFF	;	$0E
	.db	0xFF	;	$0F

	.db	0xFF	;	$10
	.db	0x65	;	$11	RALT
	.db	0xFF	;	$12	1ST SCANCODE OF PRTSCR -> NOTHING
	.db	0xFF	;	$13
	.db	0x63	;	$14	RCTRL -> CTRL
	.db	0xFF	;	$15
	.db	0xFF	;	$16
	.db	0xFF	;	$17
	.db	0xFF	;	$18
	.db	0xFF	;	$19
	.db	0xFF	;	$1A
	.db	0xFF	;	$1B
	.db	0xFF	;	$1C
	.db	0xFF	;	$1D
	.db	0xFF	;	$1E
	.db	0x66	;	$1F	LWIN -> LAMIGA

	.db	0xFF	;	$20
	.db	0xFF	;	$21
	.db	0xFF	;	$22
	.db	0xFF	;	$23
	.db	0xFF	;	$24
	.db	0xFF	;	$25
	.db	0xFF	;	$26
	.db	0x67	;	$27	RWIN -> RAMIGA
	.db	0xFF	;	$28
	.db	0xFF	;	$29
	.db	0xFF	;	$2A
	.db	0xFF	;	$2B
	.db	0xFF	;	$2C
	.db	0xFF	;	$2D
	.db	0xFF	;	$2E
	.db	0x84	;	$2F	MENU -> LAMIGA-M (special)

	.db	0xFF	;	$30
	.db	0xFF	;	$31
	.db	0xFF	;	$32
	.db	0xFF	;	$33
	.db	0xFF	;	$34
	.db	0xFF	;	$35
	.db	0xFF	;	$36
	.db	0xFF	;	$37	POWER -> NOTHING
	.db	0xFF	;	$38
	.db	0xFF	;	$39
	.db	0xFF	;	$3A
	.db	0xFF	;	$3B
	.db	0xFF	;	$3C
	.db	0xFF	;	$3D
	.db	0xFF	;	$3E
	.db	0xFF	;	$3F	SLEEP -> NOTHING

	.db	0xFF	;	$40
	.db	0xFF	;	$41
	.db	0xFF	;	$42
	.db	0xFF	;	$43
	.db	0xFF	;	$44
	.db	0xFF	;	$45
	.db	0xFF	;	$46
	.db	0xFF	;	$47
	.db	0xFF	;	$48
	.db	0xFF	;	$49
	.db	0x5C	;	$4A	KEYPAD /
	.db	0xFF	;	$4B
	.db	0xFF	;	$4C
	.db	0xFF	;	$4D
	.db	0xFF	;	$4E
	.db	0xFF	;	$4F

	.db	0xFF	;	$50
	.db	0xFF	;	$51
	.db	0xFF	;	$52
	.db	0xFF	;	$53
	.db	0xFF	;	$54
	.db	0xFF	;	$55
	.db	0xFF	;	$56
	.db	0xFF	;	$57
	.db	0xFF	;	$58
	.db	0xFF	;	$59
	.db	0x43	;	$5A	KEYPAD ENTER
	.db	0xFF	;	$5B
	.db	0xFF	;	$5C
	.db	0xFF	;	$5D
	.db	0xFF	;	$5E	WAKE UP -> NOTHING
	.db	0xFF	;	$5F

	.db	0xFF	;	$60
	.db	0xFF	;	$61
	.db	0xFF	;	$62
	.db	0xFF	;	$63
	.db	0xFF	;	$64
	.db	0xFF	;	$65
	.db	0xFF	;	$66
	.db	0xFF	;	$67
	.db	0xFF	;	$68
	.db	0x81	;	$69	END -> RSHIFT-CURSORRIGHT (special)
	.db	0xFF	;	$6A
	.db	0x4F	;	$6B	CURSORLEFT
	.db	0x80	;	$6C	HOME -> RSHIFT-CURSORLEFT (special)
	.db	0xFF	;	$6D
	.db	0xFF	;	$6E
	.db	0xFF	;	$6F

	.db	0x5F	;	$70	INSERT -> HELP
	.db	0x46	;	$71	DELETE
	.db	0x4D	;	$72	CURSORDOWN
	.db	0xFF	;	$73
	.db	0x4E	;	$74	CURSORRIGHT
	.db	0x4C	;	$75	CURSORUP
	.db	0xFF	;	$76
	.db	0xFF	;	$77
	.db	0xFF	;	$78
	.db	0xFF	;	$79
	.db	0x83	;	$7A	PGDN -> RSHIFT-CURSORDOWN
	.db	0xFF	;	$7B
	.db	0x5A	;	$7C	2ND SCANCODE OF PTRSCR -> KEYPAD (
	.db	0x82	;	$7D	PGUP -> RSHIFT-CURSORUP
	.db	0xFF	;	$7E
	.db	0xFF	;	$7F

;E0 scantable ends

; remark: since parts $80-$FF are not mapped (except for F7 - handled by prog), they're skipped
