;----------------------------------------------------------------------------
;	Empty.mcm by Guido Mersmann
;----------------------------------------------------------------------------
	include "Include.i"
	;include "SRC.MC_ModuleInclude"
	output Sourcecodes:MCControl/Modules/Empty.mcm
	opt o+,w-
;----------------------------------------------------------------------------
Version = 1
Revision = 12
Day = 19
Month = 02
Year = 2000
;----------------------------------------------------------------------------
;--- Macros
Version_String	MACRO
	dc.b "$VER: ",\1,' \<Version>.\<Revision>'," (\<Day>.\<Month>.\<Year>) ",'\2',0
	ENDM
;----------------------------------------------------------------------------
;--- Your defines

;----------------------------------------------------------------------------
	RSSET Module_SIZEOF
;--- User Data
Module_UserData	rs.b 0
;--- Insert Userdata here!
Module_UserData_End	rs.b 0
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
DModule_Code	rts
DModule_Version	dc.w Module_VersionNumber
DModule_ID	dc.l Module_Identifier
DModule_Flags	dc.l ModuleF_EnableModuleInfo ;(ModuleF_xxxx)
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
Module_VersionString	Version_String "Empty.mcm",<by Guido Mersmann>
	even
;----------------------------------------------------------------------------
DModule_Open
DModule_Close
DModule_AccessDirectFrame
DModule_AccessDirectPage
DModule_AccessRawFrame
DModule_AccessRawPage
	moveq	#Module_Error_NoError,d0
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
