
* *** xtext.asm *************************************************************
*
* XText  --  The XText Routine
* (from the FastText algorithms created in January, 1986)
*   from Book 1 of the Amiga Programmers' Suite by RJ Mical
*
* Copyright (C) 1986, 1987, Robert J. Mical
* All Rights Reserved.
*
* Created for Amiga developers.
* Any or all of this code can be used in any program as long as this
* entire copyright notice is retained, ok?  Thanks.
*
* The Amiga Programmer's Suite Book 1 is copyrighted but freely distributable.
* All copyright notices and all file headers must be retained intact.
* The Amiga Programmer's Suite Book 1 may be compiled and assembled, and the 
* resultant object code may be included in any software product.  However, no 
* portion of the source listings or documentation of the Amiga Programmer's 
* Suite Book 1 may be distributed or sold for profit or in a for-profit 
* product without the written authorization of the author, RJ Mical.
* 
* HISTORY       Name             Description
* ------------  ---------------  -------------------------------------------
* 27 Oct 86     RJ Mical >:-{)*  Translated this file.
*
* ***************************************************************************

	INCLUDE "xtext.i"


	IFND	AZTEC ; If AZTEC not defined, do it the standard way
	XDEF	_XText
	XREF	_custom
	XREF	_GfxBase
	ENDC
	IFD	AZTEC ; If AZTEC defined, do it the non-standard way (sigh)
	PUBLIC	_XText
	PUBLIC	_custom
	PUBLIC	_GfxBase
	ENDC



_XText:
* ***************************************************************************
* These FastText algorithms were created by =Robert J. Mical= in January 1986
* Copyright (C) 1986, =Robert J. Mical=
* All Rights Reserved
*
* This is my brute-force XText() routine.
* It presumes many things about text:  that the characters come in
* pairs, that the characters are 8-bits wide (this one is not easily 
* undone), and more.
*
* The theory of operation here is that I will build a single plane of
* normal characters (character data bits set, background bits clear)
* in the Normal Text Plane, using the data from the Output Characters
* Buffer.  As needed, I will invert this plane (character bits clear,
* background bits set) into the Inverted Text Plane.  There's two other
* globally accessible (pre-initialized) planes used:  an AllClearPlane plane
* of all bits clear, and an AllSetPlane plane of all bits set.
*
* Using these four planes, I can construct a bitmap of all possible pen
* settings for the foreground and background.  If corresponding bits
* in the FgPen and BgPen are:
*        -----      -----
*          0       0        Use All Clear Plane
*          0       1        Use Inverted Text Plane
*          1       0        Use Normal Text Plane
*          1       1        Use All Set Plane
*
* Note that if FgPen and BgPen are equal, I don't have to bother
* constructing the Normal or Inverted Text Planes, since they'll
* never be used.
*
* An optimization that evolves out of this fact is that you can fill a line
* or part of a line of your text with spaces (blank characters) much more
* quickly by setting the foreground pen equal to the background pen.  The
* trick with this optimization is to not spend too much time detecting
* whether or not an area of text is all blank, for you may lose the
* increased performance during the handling of normal text lines.
*
* A further optimization is that I'm guessing that many text calls
* will not require the inverted plane, so I won't make it until I 
* discover that I need it.  If programmers follow the
* Intuition-encouraged standard of pen 1 for foreground and pen 0
* for background, then the bits are:  FgPen -- 00001
*                                     BgPen -- 00000
* In fact, if the text is *any* color against a background of zero,
* this optimization works.
*
* For example, the plain PC monochrome text turns out to be pen 1 on
* pen 0.  No need to invert here!
*
* So I won't bother constructing the inverted plane until I discover
* that it's needed.  The cost of this is that I have to check a flag
* once per time that I find an inverted bit plane is called for (6 times 
* maximum (though of course Dale would say 8 times maximum)), and the 
* savings is avoiding an unnecessary inversion.
*
* Note that this routine works with character pairs while building the
* buffer.  If you specify an odd number of characters, this routine will 
* round up the character count to the next higher even number, and then 
* build the buffer with that many characters.  However, only the number
* of characters you specify will actually be printed to the screen.
*
* ON ENTRY (on stack):
*       ARG0 = address of the XTextSupport structure
*       ARG1 = address of the text string
*       ARG2 = character count
*       ARG3 = x position for text output
*       ARG4 = y position for text output

DREGS EQU	0	  ; Offset to the pushed D-Registers
DREGCOUNT EQU	6	  ; How many D-Registers were pushed
AREGS EQU	(DREGS+(DREGCOUNT*4)) ; Offset to the pushed A-Registers
AREGCOUNT EQU	5
FRONTPEN EQU	(AREGS+(AREGCOUNT*4))	; Local variable
BACKPEN  EQU	(FRONTPEN+2)	; Local variable
DRAWMODE EQU	(BACKPEN+2) ; Local variable
XBLTSIZE EQU	(DRAWMODE+2)
RETADDR  EQU	(XBLTSIZE+2)	; Our return address
ARG0  EQU	(RETADDR+4) ; Offset to passed arguments
ARG1  EQU	(ARG0+4)
ARG2  EQU	(ARG1+4)
ARG3  EQU	(ARG2+4)
ARG4  EQU	(ARG3+4)


	LEA	-8(SP),SP		; Reserve memory for local variables
	MOVEM.L A2-A6/D2-D7,-(SP)


	MOVE.L	ARG0(SP),A2	; Get the XTextSupport structure address
	MOVE.L	#_custom,A5	; Get the address of the custom chip
	MOVE.L	_GfxBase,A6	; Load up A6 for graphics calls


* Check the character count.
* If it's zero, then split as there's nothing to do.
* If it's less than zero, this is the signal that the programmer
* wants *us* to figure out how long the string is.  Nice touch, eh?
* If it's greater than zero, then presume it's valid.
	MOVE.W	ARG2+2(SP),D2	; Get the character count
	BEQ	RETURN		; and split if there's none to do
	BGT	GOT_TEXT_COUNT	; If greater than zero, then it's real

	MOVE.L	ARG1(SP),A4	; Address of text string
	MOVEQ.L	#-1,D2		; Start with less than no characters
10$	ADDQ.W	#1,D2		; Increment character count
	TST.B	(A4)+		; Test if next is end of text
	BNE	10$		; Branch if not

	MOVE.W	D2,ARG2+2(SP)	; Save as character count

GOT_TEXT_COUNT:
* The result of the following 3 instructions is created by the 2 below
* I include this commentary to keep things from getting confusing
*  ADDQ  #1,D2	 ; to round up
*  LSR.B #1,D2	 ; Turn the char count into a pair count
*  SUBQ.W	#1,D2	 ; (-1 for DBRA of PAIRLOOP below)
	SUBQ.B	#1,D2
	LSR.B	#1,D2


	CALLSYS OwnBlitter	; Get that blitter


* Get local copies of the pens, jazzed around to take the DrawMode into
* account.  Namely, if JAM1 then the background pen is automatically zero,
* and if the INVERSVID flag is set then swap the foreground/background pens

	CLEAR	D3		; Save them as words
	MOVE.B	xt_FrontPen(A2),D3 ; Load up the local front pen
	CLEAR	D4		; Start out presuming that back is zero
	MOVE.B	xt_DrawMode(A2),D5 ; Test the draw mode 
	MOVE.B	D5,D6		; Save a copy
	ANDI.W	#3,D5		; Strip off INVERSVID (and any other) bit
	MOVE.W	D5,DRAWMODE(SP)	; and save the true drawmode
	CMP.B	#RP_JAM1,D5	; Is it JAM1?
	BEQ	1$		; If it's JAM1, leave the local back as zero
	MOVE.B	xt_BackPen(A2),D4 ; else load up the local back pen

1$	ANDI.B	#RP_INVERSVID,D6 ; Was INVERSVID bit set?
	BEQ	2$		; and skip if not
	EXG	D3,D4		; else exchange the pen registers

2$
	MOVE.W	D3,FRONTPEN(SP)	; Save the local front pen
	MOVE.W	D4,BACKPEN(SP)	; Save the local back pen


	MOVE.W	xt_CharHeight(A2),D6	; Build the bltsize word
	LSL.W	#6,D6		; Height is shifted over as blitter likes it
	MOVE.W	D6,XBLTSIZE(SP)	; Save this partial for later


	CMP.W	D3,D4		; Are the pens equal?
	BEQ	PLANESET	; If so, skip building the planes


* Wait 'til any blitting is done, and then initialize 
* the blitter for my personal use ...
	CALLSYS	WaitBlit	; and wait for that baby to be free!


	CLEAR	D3
	MOVE.W	D3,bltamod(A5)	; Set up the SRCA and SRCB modulos
	MOVE.W	D3,bltbmod(A5)
	SUBI.W	#1,D3
	MOVE.W	D3,bltafwm(A5)	; Masks are all set
	MOVE.W	D3,bltalwm(A5)

	CLEAR	D3
	MOVE.B	xt_MaxTextWidth(A2),D3
	SUBQ.W	#2,D3
	MOVE.W	D3,bltdmod(A5)
	MOVE.W	#$0DFC,bltcon0(A5)	; Use ABD, minterm is A or B, don't
	MOVE.W	#$8000,bltcon1(A5)	; shift A, shift B by 8

	MOVE.L	xt_NormalTextPlane(A2),D3 ; Address of the normal text plane

	MOVE.W	xt_FontSelect(A2),D6	; Get the address of the font data
	LSL.W	#2,D6
	LEA	xt_FontData(A2),A3
	ADD.W	D6,A3
	MOVE.L	(A3),A3
	MOVE.L	ARG1(SP),A4	; Address of text string

	MOVE.W	xt_CharHeight(A2),D7

	MOVE.W	xt_Flags(A2),D6	; Get the Flags
	ANDI	#SLIM_XTEXT,D6	; and test if the programmer wants SLIM_XTEXT
	BNE	SLIM_CHARS	; and go build the text the "slim" way if so
				; else we're doing text the faster "fat" way

	MOVE.W	XBLTSIZE(SP),D6	; Get the blit size partial
	ORI	#1,D6		; and make blit size one word wide

	CMPI	#8,D7		; Can we do fast building?
	BNE	SLOW_PAIRLOOP	; If not 8, do it the "slow" way


PAIRLOOP:
* The normal text plane is constructed here.
* Do as much pre-calculating as possible before actually waiting for the
* blitter to be ready for re-use.


	CLEAR	D4		; Get the address of the font data of
	MOVE.B	(A4)+,D4	; the next character
	LSL.W	#4,D4		; (This presumes that each char is 16 bytes)
	ADD.L	A3,D4

	CLEAR	D5		; Get font data of next in pair (if there's
	MOVE.B	(A4)+,D5	; not really a second character (odd-numbered
	LSL.W	#4,D5		; string lengths) then this second move of
	ADD.L	A3,D5		; data will be unnecessary, but at least is
				; harmless since the buffer is *always*
				; pair-sized and the speed improvement is
				; great when handling two characters at once)

	CALLSYS	WaitBlit	; (this is redundant the first time through)

	MOVE.L	D4,bltapt(A5)
	MOVE.L	D5,bltbpt(A5)
	MOVE.L	D3,bltdpt(A5)

	MOVE.W	D6,bltsize(A5)	; Bombs away!

	ADDQ.L	#2,D3		; Advance destination pointer to next word

	DBRA	D2,PAIRLOOP

* Done, so go start setting up the planes 
	BRA	PLANESET


SLOW_PAIRLOOP:
* The normal text plane is constructed here.
* Done the "slow" way using a MULU because the character height isn't 8.
* Do as much pre-calculating as possible before actually waiting for the
* blitter to be ready for re-use.


	CLEAR	D4		; Get the address of the font data of
	MOVE.B	(A4)+,D4	; the next character
	ADD.W	D4,D4
	MULU	D7,D4		; Offset * 2 * CharHeight
	ADD.L	A3,D4

	CLEAR	D5		; Get font data of next in pair (if there's
	MOVE.B	(A4)+,D5	; not really a second character (odd-numbered
	ADD.W	D5,D5		; string lengths) then this second move of
	MULU	D7,D5
	ADD.L	A3,D5		; data will be unnecessary, but at least is
				; harmless since the buffer is *always*
				; pair-sized and the speed improvement is
				; great when handling two characters at once)

	CALLSYS	WaitBlit	; (this is redundant the first time through)

	MOVE.L	D4,bltapt(A5)
	MOVE.L	D5,bltbpt(A5)
	MOVE.L	D3,bltdpt(A5)

	MOVE.W	D6,bltsize(A5)	; Bombs away!

	ADDQ.L	#2,D3		; Advance destination pointer to next word

	DBRA	D2,SLOW_PAIRLOOP

* Done, so go start setting up the planes 
	BRA	PLANESET



SLIM_CHARS:
* OK, the programmer asked for SLIM_XTEXT, which is the half-size memory 
* buffer for text to be built using the processor rather than the blitter

	MOVE.L	A5,-(SP)		; Save A5 during the SLIM build

	CLEAR	D0			; Build the byte-size modulo
	MOVE.B	xt_MaxTextWidth(A2),D0
	SUBQ	#1,D0

	MOVE.W	D7,D1			; Build the line height (-1 for DBRA)
	SUBQ	#1,D1
	CMPI	#8,D7			; Can we do fast building?
	BNE	SLIM_SLOW_PAIRLOOP	; If not 8, do it the "slow" way


SLIM_PAIRLOOP:
* The normal "slim" text plane is constructed here.

	CLEAR	D4		; Get the address of the font data of
	MOVE.B	(A4)+,D4	; the next character
	LSL.W	#3,D4		; (This presumes that each char is 8 bytes)
	ADD.L	A3,D4
	MOVE.L	D4,A0

	CLEAR	D5		; Get font data of next in pair (if there's
	MOVE.B	(A4)+,D5	; not really a second character (odd-numbered
	LSL.W	#3,D5		; string lengths) then this second move of
	ADD.L	A3,D5		; data will be unnecessary, but at least is
	MOVE.L	D5,A1
				; harmless since the buffer is *always*
				; pair-sized and the speed improvement is
				; great when handling two characters at once)

	MOVE.W	D1,D6		; Build the bltsize word
	MOVE.L	D3,A5

SLIM_BUILD:
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A1)+,(A5)
	ADD.L	D0,A5
	DBRA	D6,SLIM_BUILD

	ADDQ.L	#2,D3		; Advance destination pointer to next word

	DBRA	D2,SLIM_PAIRLOOP ; Count down the character pairs to print 

	MOVE.L (SP)+,A5		; Restore A5 at end of SLIM_BUILD 

* Done, so go start setting up the planes 
	BRA	PLANESET



SLIM_SLOW_PAIRLOOP:
* The normal "slim" text plane is slowly constructed here, slow because 
* the characters are other than 8 lines tall.

	CLEAR	D4		; Get the address of the font data of
	MOVE.B	(A4)+,D4	; the next character
	MULU	D7,D4
	ADD.L	A3,D4
	MOVE.L	D4,A0

	CLEAR	D5		; Get font data of next in pair (if there's
	MOVE.B	(A4)+,D5	; not really a second character (odd-numbered
	MULU	D7,D5		; string lengths) then this second move
	ADD.L	A3,D5		; will be unnecessary, but at least is
	MOVE.L	D5,A1
				; harmless since the buffer is *always*
				; pair-sized and the speed improvement is
				; great when handling two characters at once)

	MOVE.W	D1,D6		; Build the bltsize word
	MOVE.L	D3,A5

SLIM_SLOW_BUILD:
	MOVE.B	(A0)+,(A5)+
	MOVE.B	(A1)+,(A5)
	ADD.L	D0,A5
	DBRA	D6,SLIM_SLOW_BUILD

	ADDQ.L	#2,D3		; Advance destination pointer to next word

	DBRA	D2,SLIM_SLOW_PAIRLOOP ; Count down the pairs to print 

	MOVE.L (SP)+,A5		; Restore A5 at end of SLIM_BUILD 

* Done, so fall into starting setting up the planes 



PLANESET:
* Well, that was quick, wasn't it.  Here all of the required planes (except
* the bothersome Inverted Text Plane) are ready to go.	So let's figure
* out how to initialize the plane pointers in the BitMap ...

	LEA	xt_TextBitMap(A2),A3
	LEA	bm_Planes(A3),A4	; Get address of first plane pointer

	CLEAR	D0			; Set up the pen-test mask
	MOVE.W	FRONTPEN(SP),D1		; Fetch the foreground pen
	MOVE.W	BACKPEN(SP),D2		; and the background pen
	CLEAR	D3
	MOVE.B	bm_Depth(A3),D3		; Get the BitMap depth ...
	SUBQ.W	#1,D3			; ... and set the loop count for DBRA
	CLEAR	D4			; Clear the Inverted flag


PLANELOOP:
* First, find out if the foreground/background pattern for this plane 
* is 00, 01, 10 or 11.  based on the pattern, select the associated 
* plane pointer for the BitMap
	BTST	D0,D1		; If the bit is set in the foreground pen
	BNE	PAT_ONE		; then go process 1x combinations

* Else we have a 0x combination.  Which one is it?
	BTST	D0,D2		; This time test the background pen
	BNE	PAT_01		; and if set then our pattern is 01

PAT_00:
	MOVE.L	xt_AllClearPlane(A2),A3 ; This plane is the 00 plane
	BRA	PLANE_STUFF

PAT_01:
* The dreaded Inverse Text Plane selector.  If it doesn't exist yet,
* I have to create it now.
	MOVE.L	xt_InverseTextPlane(A2),A3 ; This plane is the inverse plane
	TST.B	D4		; Test our Inverted Plane flag
	BNE	PLANE_STUFF	; and skip this mess if it's already set
				; else we'll have to invert it.
	ADDQ.B	#1,D4		; Set the inversion flag

* OK, so use the blitter inversion algorithm:  Dest = NOT SRC.

	CLEAR	D5
	MOVE.B	xt_MaxTextWidth(A2),D5 ; Build the Group-of-2 values:
	MOVE.W	ARG2+2(SP),D6
	ADDQ.W	#1,D6		; Get the first multiple of 2 that's greater
	ANDI.W	#$FFFE,D6	; than or equal to the character count, and
	SUB.W	D6,D5		; subtract that from the total buffer width
				; to make the Group-of-2 row modulo

	LSR.W	#1,D6		; Turn char count into pair count
	OR.W	XBLTSIZE(SP),D6	; and prepare for starting the blitter
 
	MOVEM.L	D0-D1,-(SP)
	CALLSYS	WaitBlit	; Wait for the blitter before I jam it.
	MOVEM.L	(SP)+,D0-D1

	MOVE.L	xt_NormalTextPlane(A2),bltbpt(A5)
	MOVE.L	A3,bltdpt(A5)

	MOVE.W	D5,bltbmod(A5)	; Set up the SRCB and DEST modulos
	MOVE.W	D5,bltdmod(A5)

	MOVE.W	#$0533,bltcon0(A5)
	MOVE.W	#$0000,bltcon1(A5)

	MOVE.W	D6,bltsize(A5)	; Bombs away!
			
	BRA	PLANE_STUFF


PAT_ONE:
* We've got a 1x pattern.  Which one do you suppose it is?  Hmm ...
	BTST	D0,D2		; This time, test the back pen only
	BNE	PAT_11


PAT_10:
* Normal Text Plane?  No problem.
	MOVE.L	xt_NormalTextPlane(A2),A3
	BRA	PLANE_STUFF

PAT_11:
	MOVE.L	xt_AllSetPlane(A2),A3	; This plane must have all bits set

* and fall into ...


PLANE_STUFF:
* OK, so A3 has the address of this plane's data.  Stuff that baby
* into the BitMap structure.
	MOVE.L	A3,(A4)+

	ADDQ	#1,D0		; Advance our mask to the next position

	DBRA	D3,PLANELOOP	; Loop on the depth of the BitMap


* Now, all done with the private use of the blitter.  Here, I would prefer
* to retain exclusive use of the blitter even throughout the call to
* BlitBMRP below, but the system won't let me.  Too bad!


	CALLSYS	DisownBlitter


* Well, now the BitMap is all ready to blast out our new line
* of text.  Wasn't that fun?  Now the simple final stroke:  zap that
* data into the RastPort, using the ever-popular, cleverly-named
* BltBitMapRastPort function (if Dale wasn't so good, I'd suggest
* that we take him out and shoot him for that name).
*
* BlitBMRP wants:
*
* A0 = Source BitMap  
* A1 = Destination RastPort
* A6 = GfxBase
*
* D0 = Source X
* D1 = Source Y
* D2 = Destination X
* D3 = Destination Y
* D4 = Pixel Width of block to be moved
* D5 = Scan-line Height of block to be moved
* D6 = Minterm

	CLEAR	D5
	MOVE.W	xt_CharHeight(A2),D5	; Height of transfer

	MOVE.W	#XTEXT_CHARWIDTH,D4	; Create the blit width ...
	MOVE.W	ARG2+2(SP),D3		; Character count
	MULU	D3,D4			; Width of transfer (creates LONG)
 
	MOVE.L	ARG4(SP),D3		; Get the Y position into D3
	MOVE.L	ARG3(SP),D2		; Get the X position into D2

	CLEAR	D1			; Source x and y are 0
	CLEAR	D0

	MOVE.L	xt_OutputRPort(A2),A1	; and get the RPort of the display

	LEA	xt_TextBitMap(A2),A0	; Get the address of the BitMap arg

* The DrawMode defines what minterm we use and which routine we call.
	CMP.W	#RP_JAM1,DRAWMODE(SP)	; Are we doing JAM1?
	BEQ	DO_JAM1

* The DrawMode can be JAM2 or COMPLEMENT.  Which is it, hmm?
	MOVE.L	#$C0,D6			; Minterm (simple transfer) for JAM2
	CMP.W	#RP_JAM2,DRAWMODE(SP)	; Is it really JAM2?
	BEQ	BBMRP			; Branch if so

	MOVE.L	#$60,D6			; Only other is complement mode

BBMRP:
	CALLSYS	BltBitMapRastPort	; Do the normal (fast) BBMRP
	BRA	RETURN


DO_JAM1:
* Call BltMaskBitMapRastPort, which is the same as BBMRP except that a
* mask is used to cookie-cut the source into the destination.
* JAM1 requires a mask, because JAM1 is cookie-cut!
* The mask goes into A2.  If either pen was non-zero then we built 
* the normal plane so use that as the mask,
* else use the AllZeroPlane for the mask (which produces zip imagery!).
* The minterm sez:  cut me in, daddio.

	MOVE.B	xt_DrawMode(A2),D6	; Was this inverse video?
	ANDI.B	#RP_INVERSVID,D6
	BNE	1$			; If so, use inverse JAM1 minterm
	MOVE.L	#$E0,D6			; else use normal JAM1 minterm
	BRA	2$

1$	MOVE.L	#$B0,D6

2$	TST.W	FRONTPEN(SP)		; Was the front pen zero?
	BNE	3$			; If not then get Normal for mask
	TST.W	BACKPEN(SP)		; Was the back pen zero?
	BNE	3$			; If not then get Normal for mask
	MOVE.L	xt_AllClearPlane(A2),A2	; AllClearPlane is the mask
	BRA	4$

3$	MOVE.L	xt_NormalTextPlane(A2),A2 ; use the plane as the mask

4$	CALLSYS	BltMaskBitMapRastPort	; Do the not-as-fast BMBMRP



RETURN:
	MOVEM.L	(SP)+,A2-A6/D2-D7
	LEA	8(SP),SP		; Release memory of local variables

	RTS


	END


