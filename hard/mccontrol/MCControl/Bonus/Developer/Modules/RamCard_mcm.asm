;----------------------------------------------------------------------------
;	RamCard.mcm by Guido Mersmann
;----------------------------------------------------------------------------
; This is an example code! I didn´t made any optimizations to make the
; code easy to understand! So don´t blame me!
;----------------------------------------------------------------------------
	include "Include.i"
	;include "SRC.MC_ModuleInclude"
	output Sourcecodes:MCControl/Modules/RamCard.mcm
	opt o+,w-
;----------------------------------------------------------------------------
Version = 1
Revision = 12
Day = 19
Month = 2
Year = 2000
;----------------------------------------------------------------------------
;--- Macros
Version_String	MACRO
	dc.b "$VER: ",\1,' \<Version>.\<Revision>'," (\<Day>.\<Month>.\<Year>) ",'\2',0
	ENDM
;----------------------------------------------------------------------------
;--- Your defines
;----------------------------------------------------------------------------
Card_Frame_SIZEOF	= 128
;----------------------------------------------------------------------------
	RSSET Module_SIZEOF
;--- User Data
Module_UserData	rs.b 0
;--- Insert Userdata here!
Module_CurrentPage	rs.l 1
Module_UserData_End	rs.b 0
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
DModule_Code	rts
DModule_Version	dc.w Module_VersionNumber
DModule_ID	dc.l Module_Identifier
DModule_Flags	dc.l ModuleF_AccessDirectFrame|ModuleF_AccessDirectPage|ModuleF_EnableMultiPage|ModuleF_EnableModuleInfo
DModule_Exec_Base	dc.l 0 ;Filled by MCControl
DModule_Dos_Base	dc.l 0 ;Filled by MCControl
DModule_Intuition_Base	dc.l 0 ;Filled by MCControl
;--- Card Data
	ds.l 14 ;Reserved
;--- Jump Table
DModule_Delay	bra DModule_Info
	nop
	bra DModule_Open
	nop
	bra DModule_Close
	nop
	ds.w 3*7 ;Reserved
	bra DModule_AccessDirectFrame
	nop
	bra DModule_AccessDirectPage
	nop
	bra DModule_AccessRawFrame
	nop
	bra DModule_AccessRawPage
	nop
	ds.w 3*6 ;Reserved
	ds.b Module_UserData_End-Module_UserData
;----------------------------------------------------------------------------
Module_VersionString	Version_String "RamCard.mcm",<by Guido Mersmann>
	even
;----------------------------------------------------------------------------
DModule_Open	lea	RAMCARD_Page1,a0
	move.l	a0,Module_CurrentPage(a4)
DModule_Close
DModule_AccessRawFrame
DModule_AccessRawPage	moveq	#Module_Error_NoError,d0
	rts
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;	DModule_Info
;	>a0.l Pointer on Destination
;	>d0.l Pointer on Lenght
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
DModule_Info	lea	Module_VersionString+6(pc),a1
.Copy_Version	move.b	(a1)+,d0
	move.b	d0,(a0)+
	cmp.b	#"(",d0
	bne	.Copy_Version
	subq.w	#2,a0
	clr.b	(a0)
	moveq	#Module_Error_NoError,d0
	rts
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;	DModule_DirectFrame
;	>a0.l Pointer on Buffer
;	>d0.w Number of Frame
;	<d0.l NULL = OK, -1 = Error
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
DModule_AccessDirectFrame
	ext.l	d0
	subq.l	#Module_AccessDirect_Write,d1
	beq	Card_WriteFrame
;----------------------------------------------------------------------------
Card_ReadFrame	move.l	Module_CurrentPage(a4),a1
	mulu	#Card_Frame_SIZEOF,d0
	add.l	d0,a1
	moveq	#Card_Frame_SIZEOF-1,d0
.Loop	move.b	(a1)+,(a0)+
	dbra	d0,.Loop
	moveq	#Module_Error_NoError,d0
	rts
;----------------------------------------------------------------------------
Card_WriteFrame	move.l	Module_CurrentPage(a4),a1
	mulu	#Card_Frame_SIZEOF,d0
	add.l	d0,a1
	moveq	#Card_Frame_SIZEOF-1,d0
.Loop	move.b	(a0)+,(a1)+
	dbra	d0,.Loop
	moveq	#Module_Error_NoError,d0
	rts
;----------------------------------------------------------------------------
;	DModule_DirectPage
;	>d0.w Number
;	>d1.l Mode
; We only have two pages, so there is no need to check d1 for Next or Prev
; Page!!
;----------------------------------------------------------------------------
DModule_AccessDirectPage
	lea	RAMCARD_Page1,a0
	lea	RAMCARD_Page2,a1
	cmp.l	Module_CurrentPage(a4),a1
	beq	.UseA0
	move.l	a1,a0
.UseA0	move.l	a0,Module_CurrentPage(a4)
	moveq	#Module_Error_NoError,d0
	rts
;----------------------------------------------------------------------------
	Section "RamCard",BSS
RAMCARD_Page1	ds.b 2*65536
RAMCARD_Page2	ds.b 2*65536
