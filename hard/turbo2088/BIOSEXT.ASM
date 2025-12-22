        NAME    BIOSEXT
        TITLE   BIOSEXT -- Extension to A2088 BIOS
        PAGE    58,132
;.............................................................................
;
;       BIOSEXT extends the BIOS of the A2088 to allow switching the cpu
;       clock speed from the keyboard. This only works with a FE2010A!
;
;       <ctrl>-<alt>-S switches to 4.77 MHz
;       <ctrl>-<alt>-M switches to 7.15 MHz
;       <ctrl>-<alt>-F switches to 9.54 MHz
;
;       Written by Eddy Olk, 1991. This source is public domain and may be
;       freely distributed and used for non-commercial purposes.
;.............................................................................

         callcombo = 0CH    ;0CH for Ctrl-Alt,
                            ;06H for Ctrl-Shift,
                            ;0AH for Shift-Alt.
         oldvec = 5CH       ;place to store original INT9 vector.

cseg     SEGMENT
         ASSUME cs:cseg, ds:cseg

         ORG  100H

begin:   jmp  install

newint09:push ax
         push ds
         sub  ax,ax
         mov  ds,ax
         mov  al,ds:[417H]               ;get keyboard flag byte
         and  al,0FH
         cmp  al,callcombo
         jne  exit
         in   al,60H                     ;read keyboard
         cmp  al,1FH  ;'S'
         je   slow
         cmp  al,32H  ;'M'
         je   medium
         cmp  al,21H  ;'F'
         je   fast
exit:    pop  ds
         pop  ax
         jmp  dword ptr cs:[oldvec]      ;jump to original keyboard routine
slow:    call reset_keyboard
         mov  al,03H
         out  63H,al
         pop  ds
         pop  ax
         iret
medium:  call reset_keyboard
         mov  al,43H
         out  63H,al
         pop  ds
         pop  ax
         iret
fast:    call reset_keyboard
         mov  al,83H
         out  63H,al
         pop  ds
         pop  ax
         iret

reset_keyboard:                          ;code to reset keyboard
         in   al,61H
         mov  ah,al
         or   al,80H
         out  61H,al
         xchg ah,al
         out  61H,al
         mov  al,20H
         out  20H,al
         ret

install: mov  ax,3509H                   ;9 is keyboard interrupt
         int  21H                        ;get old int vector
         mov  word ptr ds:[oldvec],bx    ;and save it
         mov  word ptr ds:[oldvec+2],es
         mov  dx,offset newint09
         mov  ax,2509H                   ;set new int vector with ds:dx
         int  21H
         
         mov  es,ds:[002ch]              ;Get environment segment
         mov  ah,49h
         int  21h                        ;Free it

         mov  dx,offset install          ;prepare to leave and stay resident
         int  27H

cseg     ENDS
         END begin
