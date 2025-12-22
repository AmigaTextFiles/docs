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

Main     movea.l  SysBase,A6
         move.l   CodeSize,D0
         moveq    #0,D1             ; PUBLIC
         jsr      AlcMem(A6)        ; Get the memory
         tst.l    D0                ; Did we get it?
         bne.s    GotIt
         moveq    #100,D0           ; Return Error # 100
         rts                        ; Back to AmigaDOS with error

GotIt    move.l   D0,A0             ; Move to work reg
         move.l   D0,A2             ; Save copy for patching vector
         lea      MoveMe,A1         ; Get address of our code
         move.l   CodeSize,D0       ; Number of bytes to move
         subq.l   #5,D0             ; Correct for DBF and one long word
Loop     move.b   (A1)+,(A0)+       ; Move byte
         dbf      D0,Loop
         move.l   PrivVect,(A0)+    ; Patch opcode at end
         move.l   A2,PrivVect       ; Patch us into the vector
         moveq    #0,D0             ; Good return code
         rts                        ; Back to AmigaDOS, no error

MoveMe   movem.l  D0/A0,-(SP)       ; Save registers
         move.l   8+2(SP),A0        ; Pointer to opcode
         move.w   (A0),D0           ; Pickup opcode
         andi.w   #~%111111,D0      ; Mask out EA field
         cmpi.w   #$40C0,D0         ; Is it a MOVE SR,ea?
         bne.s    NotOne
         bset     #1,(A0)           ; Convert it to MOVE CCR,ea
         movem.l  (SP)+,D0/A0       ; Restore regs
         rte                        ; Rerun new opcode

NotOne   movem.l  (SP)+,D0/A0       ; Restore regs
         jmp      $FC0000           ; To previous handler, patched on
                                    ; installation of this routine
CodeEnd
CodeSize DC.L     CodeEnd-MoveMe    ; Size of routine
         end

