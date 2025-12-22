;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; Valid for MCControl V1.40 and up!
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
Module_Identifier       = "MCCM"
Module_VersionNumber    = 1
        RSRESET
Module_Code                 rs.w 1 ;MUST $4e75 (RTS)
Module_Version              rs.w 1 ;Must be Module_VersionNumber
Module_ID                   rs.l 1 ;Must be "MCCM"
Module_Flags                rs.l 1 ;see below (unused flags must be zero)
Module_Exec_Base            rs.l 1 ;Filled by MCControl
Module_Dos_Base             rs.l 1 ;Filled by MCControl
Module_Intuition_Base       rs.l 1 ;Filled by MCControl
;--- Card Data
Module_Reserved1            rs.l 14 ;Reserved (must be ZERO)
;--- Jump Table
Module_Info                 rs.w 3
Module_Open                 rs.w 3
Module_Close                rs.w 3
Module_ReservedFunctions2   rs.w 3*7 ;Reserved
Module_AccessDirectFrame    rs.w 3
Module_AccessDirectPage     rs.w 3
Module_AccessRawFrame       rs.w 3
Module_AccessRawPage        rs.w 3
Module_ReservedFunctions3   rs.w 3*6 ;Reserved
Module_SIZEOF               rs.b 0
;----------------------------------------------------------------------------
;--- Enable transfer routines:
 BITDEF Module,AccessDirectFrame,3  ;Driver supports DirectFrameAccess
 BITDEF Module,AccessDirectPage,7   ;Driver supports DirectPageAccess
 BITDEF Module,AccessRawFrame,6     ;Driver supports RawFrameAccess
 BITDEF Module,AccessRawPage,8      ;Driver supports RawPageAccess
;--- Enable gadgets within the settings window:
 BITDEF Module,ConfigMultiPage,5    ;Driver requires MultiPage setup
 BITDEF Module,Reserved2,0          ;Must be Zero
 BITDEF Module,ConfigDevice,1       ;Driver requires an Device/Unit selector
;--- Enable special functions:
 BITDEF Module,EnableMultiPage,2    ;Turn on MultiPage support
 BITDEF Module,EnableMultiSlot,4    ;Turn on MultiSlot support
 BITDEF Module,EnableModuleInfo,9   ;Turn on DriverInfo support
;----------------------------------------------------------------------------
Module_Error_NoError       = 0
Module_Error_OpenDevice    = 1 ;Opening the given device fails!
Module_Error_NotCompatible = 2 ;If hardware supports identification!
Module_Error_NoTimerDevice = 3 ;If you need the timer.device and opening fails
Module_Error_NoParallelPort= 4 ;No ParallelPort resource
Module_Error_NoResources   = 5 ;Use for missing signals, CIA Interrupts,...
Module_Error_OutOfMemory   = 20
;----------------------------------------------------------------------------
;--- For AccessDirectFrame (Mode)
Module_AccessDirect_Read    = 0
Module_AccessDirect_Write   = 1
;--- For AccessDirectPage (Mode)
Module_AccessDirect_Up      = 0
Module_AccessDirect_Down    = 1
;----------------------------------------------------------------------------
;--- Obsolete: Do not use anymore!!!
; BITDEF Module,Device,1       ;Don´t use anymore
; BITDEF Module,MultiPage,2    ;Don´t use anymore
; BITDEF Module,DirectAccess,3 ;Don´t use anymore
; BITDEF Module,MultiSlot,4    ;Don´t use anymore
;Module_DirectFrame_Read    = 0
;Module_DirectFrame_Write   = 1
;Module_DirectPage_Next     = 0
;Module_DirectPage_Prev     = 1
;----------------------------------------------------------------------------
