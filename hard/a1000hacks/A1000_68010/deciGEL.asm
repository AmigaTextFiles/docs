;***************************************************************
;                                                              *
;       DeciGEL (Relief from MC68010 pains on the Amiga)       *
;                                                              *
; Copyright 1986 by Scott Turner                               *
; Program may be copied and used for non-commercial uses only. *
; Requests for commercial use should be directed to:           *
;                                                              *
; Scott Turner                                                 *
; 12311 Maplewood Avenue                                       *
; Edmonds, Wa 98020-1115                                       *
;                                                              *
; Execute file to install patch. May be executed over and over *
; again. You lose about 40 bytes of memory each time you       *
; execute it though. Reboot your AMiga (Ctrl-Amiga-AMiga) to   *
; remove the patch.                                            *
;                                                              *
; EXECUTE DeciGEL.make                                         *
; Assembles and links a new DeciGEL                            *
; Program should work with MC68000/MC68008/MC68012/MC68020     *
; as well (ie. it won't die on MC68000/MC68008).               *
;***************************************************************

; Some handy constants
SysBase  EQU      4
AlcMem   EQU      -6*33
PrivVect EQU      $20               ; Address of Privlege error vector

