	list	p=16c84, r=dec,	n=0

cmd_option	equ	0xed
cmd_typematic	equ	0xf3
cmd_default	equ	0xf6
cmd_resend	equ	0xfe
cmd_reset	equ	0xff
rst_warn	equ	0x78
pwr_up		equ	0xfd	;power up key stream
t_pwr_up	equ	0xfe	;terminate key stream
no_send		equ	-1	;do not send to amiga

	cblock	1
	tmr0		;timer
	pc		;lsb pc
	status
	fsr
	pa		;port a
	pb		;port b
	dummy
	eedata
	eeadr
	pclath		;msb pc latch
	intcon		;interrupt control reg.
	int_addr	;interrupt routine addr. 
	trans_addr	;trans. routine addr. 
	_byte		;byte to receive/transmit
	save_byte	;resend byte
	ami_byte	;byte to transmit -> amiga
	_temp		;rotation temp storage
	bit_cnt		;bit counter
	cnt_dwn		;count down reg.
	parity
	at_s_ret	;"at realsend routine" return addr.
	x_flag		;"xtra flag" reg.
	leds		;at-keyboard leds
	l_byte		;last received byte
	e0_l_byte	;last received 0xe0 byte
	tmr_ret		;timer return addr.
	tmr_ret_pch	;timer return pc high latch
	tmr_addr	;delay wait routine addr.
	tmr_pch		;delay wait routine pc high latch
	tmr_cntdwn	;0xff cycles in wdt lookalike routine
	tmr_ms		;remaining cycles in wdt lookalike routine
	endc

#define	carry		status,0
#define	zero		status,2
#define	rp0		status,5	;page select
#define	rd		eecon1,0	;read eeprom
#define	wr		eecon1,1	;write eeprom
#define	wren		eecon1,2	;write eeprom enable
#define	eeif		eecon1,4	;eeprom write int
#define	rbif		intcon,0	;pb change int. flag
#define	intf		intcon,1	;pb,0 int. flag
#define	t0if		intcon,2	;tmr0 int. flag
#define	rbie		intcon,3
#define	inte		intcon,4
#define	t0ie		intcon,5
#define	eeie		intcon,6
#define	gie		intcon,7	;global interrupt enable
#define	pch_0		pclath,0
#define	pch_1		pclath,1

#define	at_clk_in	pb,0
#define	at_clk_out	pb,1
#define	ami_type	pb,3		;resetmode switch
#define	at_dat_in	pb,6
#define	at_dat_out	pb,7
#define	ami_dat_out	pa,0
#define	ami_dat_in	pa,1
#define	_kbreset	pa,3
#define	ami_clk		pa,4		;open drain
#define	par_chk		_byte,7		;parity check bit
#define	_break		ami_byte,7	;break bit
#define	c_lock		leds,2		;caps lock on/off
#define	p_res		x_flag,0	;pause pressed twice chk
#define	rw_ctrl		x_flag,1	;reset warning chk bits
#define	rw_lalt		x_flag,2
#define	rw_ralt		x_flag,3
#define	rwarn		x_flag,4	;reset warning main flag
#define	tmr_tst		x_flag,5	;longdelay test bit
#define	s_break		x_flag,6	;"special mission keys" break flag
#define	sync_cd		x_flag,7	;sync countdown checkbit

	org	0		;reset vector
	movlw	0xff		;init ports
	movwf	pb
	movwf	pa
	goto	init

	org	4		;interrupt vector
	btfsc	intf		;pb,0
	goto	at_clk
;---------------------------------------------------
	bcf	t0if		;watch dog timer lookalike routine
	decfsz	tmr_cntdwn
	retfie			;65536us @ 4MHz

	btfsc	tmr_tst
	goto	tmr_end

	incf	tmr_cntdwn
	bsf	tmr_tst
	movf	tmr_ms,w
	movwf	tmr0
	movf	tmr_pch,w
	movwf	pclath
	movf	tmr_addr,w
	retfie

tmr_end	movlw	b'10001111'
	option
	movf	tmr_ret_pch,w
	movwf	pclath
	movf	tmr_ret,w
	return

tmr_init
	movwf	tmr_addr	;save wait routine addr.
	bcf	tmr_tst
	movlw	b'10000111'	;assign presc. to tmr0, presc. 256
	option
	clrf	tmr0
	movlw	b'10100000'	;gie,t0ie =enable
	movwf	intcon
	movf	tmr_pch,w
	movwf	pclath
	movf	tmr_addr,w
	return
;---------------------------------------------------
at_clk	bcf	intf
	movf	int_addr,w	;get correct int. routine
	movwf	pc
;---------------------------------------------------
wait	movwf	pc

;========-at get key-===============================
at_get_key
	movlw	at_g0
	movwf	int_addr
	movlw	b'10000010'	;set at_out
	movwf	pb
	movlw	b'10010000'	;gie,inte=enable intf=clear
at_g_st	movwf	intcon
	movlw	wait
	goto	wait

at_g0	btfsc	at_dat_in	;chk startbit =0
	goto	at_g_rint	;if not ,return interrupt

	movlw	at_g1
	movwf	int_addr
	movlw	b'01000000'	;parity chk on bit 6
	movwf	parity
	movlw	8		;8 databits
	movwf	bit_cnt
	movlw	wait
	retfie

at_g1	movf	pb,w
	movwf	_temp
	rlf	_temp
	rlf	_temp
	rrf	_byte
	btfsc	par_chk		;calc parity
	comf	parity
	decfsz	bit_cnt		;decrease bit counter
	goto	at_g_rint

	movlw	at_par_bit
	movwf	int_addr
	movf	parity,w
	andlw	b'01000000'	;mask parity bit 6
	movwf	parity
at_g_rint
	movlw	wait
	retfie

at_par_bit
	movf	pb,w		;check if received parity is correct
	andlw	b'01000000'	;mask parity bit 6
	subwf	parity
	btfsc	zero
	goto	at_stopbit

	movlw	at_g_rs		;clean up stack, before resend
	return

at_g_rs	movlw	cmd_resend	;error, please resend
	call	at_send
	goto	at_get_key

at_stopbit
	movlw	at_g3
	movwf	int_addr

	movlw	wait
	retfie

at_g3	btfss	at_clk_in	;wait clk hi
	goto	at_g3
	bcf	at_clk_out
	movlw	at_g4
at_g4	return			;return at_get_key routine
;========-at send-==================================
at_send	movwf	save_byte	;if resend
at_resend
	movwf	_byte
	clrf	intcon
	movlw	8
	movwf	bit_cnt
	movlw	1
	movwf	parity
	movlw	at_s
	movwf	int_addr
	movlw	b'10000010'	;set at_out
	movwf	pb

chk_bsy	movf	pb,w		;check if at= busy
	andlw	b'01000001'	;mask at_in bits
	sublw	b'01000001'
	btfss	zero
	goto	chk_bsy

	movlw	at_s_parity	;return addr.
	movwf	at_s_ret
	movlw	b'10010000'	;gie=enable intf=clear inte=enable
	movwf	intcon
	clrf	pclath
	movlw	wait
	bcf	at_dat_out	;tell the AT-keyb. we want to transmit
	goto	wait

at_s_parity			;parity, stop & ex bits send routine
	movf	parity,w
	iorlw	b'00000110'	;set stop & ex-bit
	movwf	_byte
	movlw	at_s_ack	;return addr.
	movwf	at_s_ret
	movlw	3
	movwf	bit_cnt
	movlw	wait
	bsf	gie		;enable ints.
	goto	wait

at_s_ack			;at send ack. routine
	btfss	at_clk_in	;test clk=hi
	goto	at_s_ack
	movlw	0xf6		;short delay
	call	delay
	bcf	at_clk_out	;ack.
	movlw	0x9c		;ca:100us
	call	delay
	call	at_get_key	;get ack. byte
	movf	_byte,w
	sublw	cmd_resend	;if equal, we'll have to  resend
	btfss	zero
	return

	movf	save_byte,w	;prepare resend
	goto	at_resend

at_s	rrf	_byte,w
	rrf	_byte
	movf	_byte,w		;real send routine
	iorlw	b'00000010'	;set at_clk_out
	movwf	pb
	btfsc	par_chk
	comf	parity
	decfsz	bit_cnt
	goto	at_s_r
	movf	at_s_ret,w
	return

at_s_r	movlw	wait
	retfie

;===================================================
_reset	btfss 	ami_type	;check resetmode
	goto	r_hardreset

	bsf	sync_cd
	movlw	10
	movwf	cnt_dwn
	movlw	rst_warn
	call	ami_send

	movlw	10
	movwf	cnt_dwn
	bsf	rwarn
	movlw	rst_warn
	call	ami_send

	movlw	r_hardreset
	movwf	tmr_ret
	clrf	tmr_ret_pch
	movlw	152		;10s
	movwf	tmr_cntdwn
	movlw	-151
	movwf	tmr_ms
	clrf	tmr_pch
	movlw	r_sync1		;wait routine addr.
	call	tmr_init

r_sync1	bcf	gie
	btfsc	ami_dat_in	;wait kdat hi. max 10s
	goto	r_hardreset
	bsf	gie
	movwf	pc

r_hardreset
	movlw	1
	movwf	tmr_ret_pch
	movlw	i_1
	movwf	tmr_ret
	movlw	7		;500ms
	movwf	tmr_cntdwn
	movlw	-161
	movwf	tmr_ms
	bcf	ami_clk		;hard reset a2000
	clrf	tmr_pch
	bcf	_kbreset	;hard reset a500/a1200
	movlw	wait
	call	tmr_init
	goto	wait

;---------------------------------------------------
r_sync	movlw	r_hardreset	;wait kdat lo ack. 250ms
	movwf	tmr_ret
	clrf	tmr_ret_pch
	movlw	3		;3*65536us
	movwf	tmr_cntdwn
	movlw	-209		;(2.5*10^5-3*65536)/256=209
	movwf	tmr_ms
	goto	rw_s
;=======-AmiSync routine-===========================
sync_up	btfss	sync_cd
	goto	sync_up1
	decf	cnt_dwn
	btfsc	zero
	goto	r_hardreset

sync_up1
	bcf	ami_dat_out	;clock out 1:s
	movlw	-20
	call	delay
	bcf	ami_clk
	movlw	-20
	call	delay
	bsf	ami_clk
	movlw	-20
	call	delay
	bsf	ami_dat_out
;	goto	ami_sync

;---------------------------------------------------
ami_sync
	movlw	sync_up
	movwf	tmr_ret
	clrf	tmr_ret_pch
	movlw	2		;2*65536us
	movwf	tmr_cntdwn
	movlw	-47		;remaining (1.43*10^5-2*65536)/256=47
	movwf	tmr_ms
rw_s	movlw	0xff		;set all ami_outputs
	movwf	pa
	clrf	tmr_pch
	movlw	sync_1		;wait routine addr.
	call	tmr_init	;init long delay

sync_1	bcf	gie
	btfss	ami_dat_in	;wait lo ack. 143ms
	goto	sync_2
	bsf	gie
	movwf	pc

sync_2	call	tmr_end		;deinit long delay

	btfsc	rwarn
	return

sync_3	btfss	ami_dat_in	;wait ack. end
	goto	sync_3
	return

	org	0x100
;=======-Delay routine-=============================
delay	movwf	tmr0
	movlw	b'10001111'
	option
	bcf	t0ie		;disable tmr int.
	bcf	t0if
dly	btfss	t0if
	goto	dly
	return

;===================================================
translate
	bsf	pch_0
	bcf	pch_1
	movf	trans_addr,w
	movwf	pc
;---------------------------------------------------
t_chk	movf	_byte,w
	sublw	0xe1		;pause
	btfsc	zero
	goto	s_pause

	bcf	p_res		;reset pause flag

	movf	_byte,w
	sublw	0xe0		;arrowkeys etc.
	btfsc	zero
	goto	t_e0

	clrf	e0_l_byte

	movf	_byte,w
	sublw	0xf0		;break code
	btfsc	zero
	goto	t_break

	bcf	s_break		;reset "special mission keys" break flag

	movf	l_byte,w	;get rid of repeating chars
	subwf	_byte,w
	btfss	zero
	goto	not_eq
	movlw	no_send
	movwf	ami_byte
	return

not_eq	movf	_byte,w
	movwf	l_byte
	goto	table

;---------------------------------------------------
t_break	clrf	l_byte
	bsf	s_break
	movlw	t_b1
	movwf	trans_addr
	movlw	no_send
	movwf	ami_byte
	return

t_b1	movlw	t_chk
	movwf	trans_addr

	movf	_byte,w
	call	table
	bsf	_break
	return
;---------------------------------------------------
t_e0	clrf	l_byte
	bcf	s_break
	movlw	t_e01
	movwf	trans_addr
	movlw	no_send
	movwf	ami_byte
	return

t_e01	movf	_byte,w
	sublw	0xf0		;break
	btfsc	zero
	goto	t_e0_b

	movlw	t_chk
	movwf	trans_addr

	movf	e0_l_byte,w	;get rid of repeating chars
	subwf	_byte,w
	btfsc	zero
	return

	movf	_byte,w
	movwf	e0_l_byte
	goto	e0_table

t_e0_b	bsf	s_break
	movlw	t_e0_b1
	movwf	trans_addr
	clrf	e0_l_byte
	return

t_e0_b1	movlw	t_chk
	movwf	trans_addr

	movf	_byte,w
	call	e0_table
	bsf	_break
	return

;=======-special mission keys-======================

s_home	btfsc	s_break
	goto	s_home_b
	movlw	0x61		;right shift
	call	ami_send
	retlw	0x4f		;arrow left
s_home_b
	movlw	0x4f+0x80
	call	ami_send
	retlw	0x61+0x80
;---------------------------------------------------
s_end	btfsc	s_break
	goto	s_end_b
	movlw	0x61		;right shift
	call	ami_send
	retlw	0x4e		;arrow right
s_end_b	movlw	0x4e+0x80
	call	ami_send
	retlw	0x61+0x80
;---------------------------------------------------
s_pageup
	btfsc	s_break
	goto	s_pageup_b
	movlw	0x61		;right shift
	call	ami_send
	retlw	0x4c		;arrow up
s_pageup_b
	movlw	0x4c+0x80	;arrow up + break
	call	ami_send
	retlw	0x61+0x80	;right shift + break
;---------------------------------------------------
s_pagedown
	btfsc	s_break
	goto	s_pagedown_b
	movlw	0x61		;right shift
	call	ami_send
	retlw	0x4d		;arrow down
s_pagedown_b
	movlw	0x4d+0x80	;arrow down + break
	call	ami_send
	retlw	0x61+0x80	;right shift + break
;---------------------------------------------------
s_c_screen
	btfsc	s_break
	goto	s_c_screen_b
	movlw	0x66		;left amiga
	call	ami_send
	retlw	0x37		;m
s_c_screen_b
	movlw	0x37+0x80	;m + break
	call	ami_send
	retlw	0x66+0x80	;left amiga + break
;---------------------------------------------------
s_ctrl	bsf	rw_ctrl
	btfsc	s_break
	bcf	rw_ctrl
	retlw	0x63
;---------------------------------------------------
s_lamiga
	bsf	rw_lalt
	btfsc	s_break
	bcf	rw_lalt
	retlw	0x66
;---------------------------------------------------
s_ramiga
	bsf	rw_ralt
	btfsc	s_break
	bcf	rw_ralt
	retlw	0x67
;---------------------------------------------------
s_caps	btfsc	s_break
	retlw	no_send

	clrf	pclath
	movlw	cmd_option
	call	at_send

	btfss	c_lock		;chk capslock= on
	goto	s_c_on

	bcf	c_lock		;capslock off
	movf	leds,w
	call	at_send
	retlw	0x62+0x80	;capslock + break

s_c_on	bsf	c_lock		;capslock on
	movf	leds,w
	call	at_send
	retlw	0x62		;capslock
;---------------------------------------------------
s_pause	clrf	l_byte
	clrf	e0_l_byte
	movlw	s_p1
	movwf	trans_addr
	movlw	7		;receive 7 more pause bytes,
	movwf	cnt_dwn		;waste of time don't u think :-)
	movlw	no_send
	movwf	ami_byte
	return

s_p1	decfsz	cnt_dwn
	return

	btfsc	p_res		;chk if pause pressed twice
	goto	_reset		;p_res = hi -> hardreset

	bsf	p_res
	movlw	t_chk
	movwf	trans_addr
	return

;===================================================
init	movlw	b'01111101'	;0=output 1=input
	tris	pb
	movlw	b'11100110'
	tris	pa
	movlw	b'10001111'	;pull up pb disable,falling edge
	option			;assign prescaler to wdt, presc. 128

;---------------------------------------------------
at_startup
	movlw	2
	movwf	tmr_ret_pch
	movlw	at_st_ret
	movwf	tmr_ret
	movlw	76		;wdt 5s
	movwf	tmr_cntdwn
	movlw	-75		;(5*10^6-76*256²)/256=75
	movwf	tmr_ms
	clrf	tmr_pch
	movlw	wait
	call	tmr_init

	movlw	at_g0
	movwf	int_addr
	movlw	b'10110000'	;gie,t0ie,inte=enable t0if,intf=reset
	call	at_g_st

;---------------------------------------------------
at_st_ret
	bcf	at_clk_out
	movlw	15		;delay 1s
	movwf	tmr_cntdwn
	movlw	-66		;(10^6-15*256²)/256=66
	movwf	tmr_ms
	movlw	1
	movwf	tmr_ret_pch
	movlw	i_1
	movwf	tmr_ret
	clrf	tmr_pch
	movlw	wait
	call	tmr_init
	goto	wait
;---------------------------------------------------

i_1	clrf	x_flag		;init "xtra flag" reg.
	clrf	l_byte		;init last byte chk
	clrf	e0_l_byte

	movlw	cmd_reset	;at reset
	call	at_send
	call	at_get_key	;receive 0xaa= bat/selftest complete

	movlw	cmd_default
	call	at_send

	movlw	cmd_option	;at option cmd.
	call	at_send

	movlw	b'00000100'	;capslock on
	call	at_send

	bsf	sync_cd		;enable sync-countdown
	movlw	50		;if sync does not arrive within 50 retries,
	movwf	cnt_dwn		;then hard reset
	call	sync_up		;synchronize with amiga

	movlw	10
	movwf	cnt_dwn
	movlw	pwr_up		;power up key stream
	call	ami_send

	movlw	10
	movwf	cnt_dwn
	movlw	t_pwr_up	;terminate key stream
	call	ami_send
	bcf	sync_cd		;disable sync-countdown

	movlw	cmd_option
	call	at_send

	clrf	leds		;all leds off
	clrw
	call	at_send

	movlw	t_chk
	movwf	trans_addr	;init trans_addr

;=======-Main Loop-=================================
loop	clrf	pclath
	call	at_get_key
	call	translate	;atcode -> amigacode

	movf	x_flag,w
	andlw	b'00001110'
	sublw	b'00001110'	;chk reset warning
	btfsc	zero
	goto	_reset

	movf	ami_byte,w
	sublw	no_send		;0xff = no amisend
	btfsc	zero
	goto	loop

	movf	ami_byte,w
	call	ami_send
	goto	loop

	org	0x200
;=======-Amiga Send-================================
ami_send
	clrf	intcon		;disable all interrupts
	movwf	ami_byte
	rlf	ami_byte,w	;put bit #7 first
	rlf	ami_byte
	comf	ami_byte	;& invert, according to rkm hw-ref
	movlw	0xff		;set ami out
	movwf	pa
	movlw	8		;8 bits to transmit
	movwf	bit_cnt

ami_out	rlf	ami_byte,w
	rlf	ami_byte
	movf	ami_byte,w
	iorlw	b'00011000'	;set ami_clk & _kbreset
	movwf	pa
	movlw	-20		;20us
	call	delay
	bcf	ami_clk
	movlw	-20
	call	delay
	bsf	ami_clk
	movlw	-20
	call	delay
	decfsz	bit_cnt
	goto	ami_out
	bsf	ami_dat_out

	btfsc	rwarn		;chk if in resetmode
	goto	r_sync		;then wait 250ms for ack.

	goto	ami_sync	;wait 143ms for ack.


	org	0x300
;======-key lookup table-===========================
e0_table
	addlw	0x70	;correct the keylookup-table to work with e0xx-codes

table	call	tab
	movwf	ami_byte
	return

tab	bsf	pch_0
	bsf	pch_1
	addwf	pc

	fill (retlw no_send),1
	retlw	0x58		;f9	=0x01
	fill (retlw no_send),1
	retlw	0x54		;f5	=0x03
	retlw	0x52		;f3	=0x04
	retlw	0x50		;f1	=0x05
	retlw	0x51		;f2	=0x06
	retlw	0x5b		;f12	=0x07 -> ]}
	fill (retlw no_send),1
	retlw	0x59		;f10	=0x09
	retlw	0x57		;f8	=0x0a
	retlw	0x55		;f6	=0x0b
	retlw	0x53		;f4	=0x0c
	retlw	0x42		;tab	=0x0d
	retlw	0x00		;`~	=0x0e
	fill (retlw no_send),2
	goto	s_lamiga	;l alt	=0x11 -> lamiga
	retlw	0x60		;l shift=0x12
	fill (retlw no_send),1
	retlw	0x64		;l ctrl	=0x14 -> lalt
	retlw	0x10		;Q	=0x15
	retlw	0x01		;1	=0x16
	fill (retlw no_send),3
	retlw	0x31		;Z	=0x1a
	retlw	0x21		;S	=0x1b
	retlw	0x20		;A	=0x1c
	retlw	0x11		;W	=0x1d
	retlw	0x02		;2	=0x1e
	fill (retlw no_send),2
	retlw	0x33		;C	=0x21
	retlw	0x32		;X	=0x22
	retlw	0x22		;D	=0x23
	retlw	0x12		;E	=0x24
	retlw	0x04		;4	=0x25
	retlw	0x03		;3	=0x26
	fill (retlw no_send),2
	retlw	0x40		;space	=0x29
	retlw	0x34		;V	=0x2a
	retlw	0x23		;F	=0x2b
	retlw	0x14		;T	=0x2c
	retlw	0x13		;R	=0x2d
	retlw	0x05		;5	=0x2e
	fill (retlw no_send),2
	retlw	0x36		;N	=0x31
	retlw	0x35		;B	=0x32
	retlw	0x25		;H	=0x33
	retlw	0x24		;G	=0x34
	retlw	0x15		;Y	=0x35
	retlw	0x06		;6	=0x36
	fill (retlw no_send),3
	retlw	0x37		;M	=0x3a
	retlw	0x26		;J	=0x3b
	retlw	0x16		;U	=0x3c
	retlw	0x07		;7	=0x3d
	retlw	0x08		;8	=0x3e
	fill (retlw no_send),2
	retlw	0x38		;;,	=0x41
	retlw	0x27		;K	=0x42
	retlw	0x17		;I	=0x43
	retlw	0x18		;O	=0x44
	retlw	0x0a		;0	=0x45
	retlw	0x09		;9	=0x46
	fill (retlw no_send),2
	retlw	0x39		;:.	=0x49
	retlw	0x3a		;_-	=0x4a
	retlw	0x28		;L	=0x4b
	retlw	0x29		;Ö	=0x4c
	retlw	0x19		;P	=0x4d
	retlw	0x0b		;+	=0x4e
	fill (retlw no_send),3
	retlw	0x2a		;Ä	=0x52
	fill (retlw no_send),1
	retlw	0x1a		;Å	=0x54
	retlw	0x0c		;=+	=0x55
	fill (retlw no_send),2
	goto	s_ctrl		;caps l.=0x58 -> ctrl
	retlw	0x61		;r shift=0x59
	retlw	0x44		;return	=0x5a
	retlw	0x1b		;]	=0x5b
	fill (retlw no_send),1
	retlw	0x2b		;*'	=0x5d
	fill (retlw no_send),3
	retlw	0x30		;<>	=0x61
	fill (retlw no_send),4
	retlw	0x41		;bs	=0x66
	fill (retlw no_send),2
	retlw	0x1d		;kp1	=0x69
	fill (retlw no_send),1
	retlw	0x2d		;kp4	=0x6b
	retlw	0x3d		;kp7	=0x6c
	fill (retlw no_send),3
	retlw	0x0f		;kp0	=0x70
	retlw	0x3c		;kp.	=0x71
	retlw	0x1e		;kp2	=0x72
	retlw	0x2e		;kp5	=0x73
	retlw	0x2f		;kp6	=0x74
	retlw	0x3e		;kp8	=0x75
	retlw	0x45		;esc	=0x76
	retlw	0x5a		;numlock=0x77
	retlw	0x0d		;f11	=0x78 -> \|
	retlw	0x5e		;kp+	=0x79
	retlw	0x1f		;kp3	=0x7a
	retlw	0x4a		;kp-	=0x7b
	retlw	0x5d		;kp*	=0x7c
	retlw	0x3f		;kp9	=0x7d
	goto	s_caps		;scrl l.=0x7e -> caps lock
	fill (retlw no_send),2
	goto	s_ramiga	;r alt	=0x11 -> ramiga
	retlw	no_send		;l shift=0x12 (numlock x-byte +lshift)
	retlw	0x56		;f7	=0x83
	retlw	0x65		;r ctrl	=0x14 -> ralt
	fill (retlw no_send),0x1f-0x14-1
	goto	s_lamiga	;win95	=0x1f
	fill (retlw no_send),0x27-0x1f-1
	goto	s_ramiga	;win95	=0x27
	fill (retlw no_send),0x2f-0x27-1
	goto	s_c_screen	;menu95	=0x2f
	fill (retlw no_send),0x4a-0x2f-1
	retlw	0x5c		;kp/	=0x4a
	fill (retlw no_send),14
	retlw	no_send		;r shift=0x59 (useless x-byte)
	retlw	0x43		;enter	=0x5a
	fill (retlw no_send),14
	goto	s_end		;end	=0x69
	fill (retlw no_send),1
	retlw	0x4f		;l arrow=0x6b
	goto	s_home		;home	=0x6c
	fill (retlw no_send),3
	retlw	0x5f		;insert	=0x70 -> help
	retlw	0x46		;delete	=0x71
	retlw	0x4d		;d arrow=0x72
	fill (retlw no_send),1
	retlw	0x4e		;r arrow=0x74
	retlw	0x4c		;u arrow=0x75
	fill (retlw no_send),4
	goto	s_pagedown	;pagedn	=0x7a
	fill (retlw no_send),1
	goto	s_c_screen	;print s=0x7c
	goto	s_pageup	;pageup	=0x7d

	end
;win95		e01f
;win95		e027
;menu95		e02f
;right alt	e011
;left shift	e012
;right ctrl	e014
;keypad div	e04a
;rshift+nlock	e0f059
;enter		e05a
;end		e069
;left		e06b
;home		e06c
;insert		e070
;delete		e071
;down		e072
;right		e074
;up		e075
;page down	e07a
;print screen	e07c
;page up	e07d
