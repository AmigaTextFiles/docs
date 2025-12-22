; PROGRAM: syncdoublerII.SRC

; July 1, 1996

;updated 23.11.1997

#define clk_dis		RB,0		;output, can start the oscillator




#define hsyncout	RA,0		;output, sync the vga monitor

#define Vsync		RA,1		;Vsync input

#define left		RA,2		;input, scroll left
#define right		RA,3		;input, scroll right



#define z		03,2		;zero bit of status register
#define c		03,0		;carry bit of status register

#define page		03,5


TMR0		=	01h
OPTION		=	81h
RA		=	05h
RB		=	06h

pcl 		=	02h
pclath		=	0ah





	cblock	0x0c
	  scroll			;scroll position register
	  count0			;counter value
	  count1
	  flags0
	endc



#define	DISPLAY_mode	flags0,0




		DEVICE	PIC16C84, XT_OSC, WDT_off	;set processor type 


		XTAL	.3546875		;set XTAL frequenzy for PICSim 




start		clrf	pclath			;clear pclatch

		bsf	page

		movlw	11111111b
		movwf	OPTION

		movlw	11111110b
		movwf	RA
		movwf	RB
		bcf	page


		clrf	RB			;clear port b


		movlw	.7			;middle scroll position
		movwf	scroll


;
;in HIRES mode the syncdoubler waits for sync and generates 2 syncs per Amiga sync
;there is a adjustable delay between Amiga sync and first generated sync
;







			
HIRES_mode	movf	scroll,w
		addwf	pcl			;jump in table
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
	
		bcf	hsyncout		;start sync
		nop
		bsf	hsyncout		;stop sync

		movlw	11111110b		;switchRGB to input
		tris	RB

		btfsc	left
		goto	do_the_left
				
		btfsc	right
		goto	do_the_right
		
		btfsc	DISPLAY_mode		;VGA or HIRES mode ?
		goto	VGA_mode
back1		nop
		nop
back3		nop
		nop
		nop
back2		nop
		nop
back4		btfsc	Vsync
		goto	:do_nothing
		call	vertical_sync
		goto	second_sync
:do_nothing	nop
		nop
		nop
		nop
		nop

second_sync	movlw	00000010b	;switch RGB to output
		tris	RB

		bcf	hsyncout	;start sync
		nop
		bsf	hsyncout	;stop sync


		bsf	clk_dis		;stops the clock if hsync from Amiga is high

		;
		;waiting....		;waiting until hsync is low (important for syncronisation)
		;


		bcf	clk_dis		;enables the clock
		goto	HIRES_mode












do_the_left	decfsz	count0		;every 256. line one step to left
		goto	back1
		incf	scroll,f
		
		movlw	.18		;limit reached ?
		subwf	scroll,w
		btfss	z
		goto	back2
		decf	scroll
		goto	back4

do_the_right	decfsz	count0		;every 256. line one step to right
		goto	back3
		decf	scroll
		movlw	.255		;limit reached ?
		subwf	scroll,w
		btfsc	z
		clrf	scroll
		goto	back4


;
;this routine checks the actuell Display mode
;


vertical_sync	decfsz	count1	
		return



		bsf	clk_dis		;stops the clock if hsync from Amiga is high
		;
		;waiting....		;waiting until hsync is low (important for syncronisation)
		;
		bcf	clk_dis		;enables the clock



		movlw	.5		;get out of sync area
		movwf	count1
:loop_1		decfsz	count1
		goto	:loop_1

		clrf	TMR0		;clear sync counter

		movlw	.5		;in this time a sync must come in VGA mode
		movwf	count1
:loop_2		decfsz	count1
		goto	:loop_2

		movf	TMR0		;sync ?
		bcf	DISPLAY_mode
		btfss	z
		bsf	DISPLAY_mode	;VGA = 1, HIRES = 0
		return




;
;in VGA mode the syncdoubler waits for sync and generates 1 sync per Amiga sync
;


VGA_mode	bsf	clk_dis		;stops the clock if hsync from Amiga is high
		;
		;waiting....		;waiting until hsync is low (important for syncronisation)
		;
		bcf	clk_dis		;enables the clock


		bcf	hsyncout	;start sync
		nop
		bsf	hsyncout	;stop sync

		btfss	Vsync
		call	vertical_sync

		btfss	DISPLAY_mode	;VGA or HIRES mode ?
		goto	HIRES_mode

		goto	VGA_mode


