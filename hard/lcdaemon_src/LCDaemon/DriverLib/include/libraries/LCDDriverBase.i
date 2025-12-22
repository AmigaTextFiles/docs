* based on samplebase.i
* Copyright (c) 1992 Commodore-Amiga, Inc. or whoever owns the Amiga this week.

   IFND  LCDDRIVER_BASE_I
LCDDRIVER_BASE_I SET 1


   IFND  EXEC_TYPES_I
   INCLUDE  "exec/types.i"
   ENDC   ; EXEC_TYPES_I

   IFND  EXEC_LIBRARIES_I
   INCLUDE  "exec/libraries.i"
   ENDC   ; EXEC_LIBRARIES_I

;--------------------------
; library data structures
;--------------------------

;  Note that the library base begins with a library node

   STRUCTURE LCDDriverBase,LIB_SIZE
   UBYTE   lcddrvb_Flags
   UBYTE   lcddrvb_pad
   ;We are now longword aligned
   ULONG   lcddrvb_SysLib
   ULONG   lcddrvb_DosLib
   ULONG   lcddrvb_SegList
   APTR    lcddrvb_Private
   LABEL   LCDDriverBase_SIZEOF


;;;SAMPLENAME   MACRO
;;;      DC.B   'xxx.library',0
;;;      ENDM

   ENDC  ;LCDDRIVER_BASE_I

