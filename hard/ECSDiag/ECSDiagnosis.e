/*      New prog to select common AMIGA ECS diagnostics */

DEF pw,a,b,c,x,y,t,more

PROC main()
SetTopaz(8)
REPEAT
a:=ecsdiagnosis('What is the primary characterist of the problem:','Blank Screen|Graphics|Ports|Mouse|Floppy|Other|Quit',0)
 SELECT a
        CASE 0
         more:=0
        CASE 1
         b:=ecsdiagnosis('What is the screen color?','Black|Green|White|Red',0)
          SELECT b
                CASE 1
                more:=ecsdiagnosis('BLACK SCREEN: M68000, Agnus, Power Supply\n              X1 28.636 Oscillator Crystal\n','More|Quit',0)
                CASE 2
                more:=ecsdiagnosis('GREEN SCREEN: Agnus, Gary, Dynamic Rams, Agnus Socket\n              A501 or similar expansion, Ram on motherboard\n              (If any ram is too hot to touch, it is bad\n','More|Quit',0)
                CASE 3
                more:=ecsdiagnosis('WHITE SCREEN: Agnus, Paula, U7 8520 CIA(U300), U37 74LS32(U302)\n              1301 1ohm Resistor, Agnus Socket \n','More|Quit',0)
                CASE 0
                more:=ecsdiagnosis('RED SCREEN: Bad ROM Chip\n','More|Quit',0)
          ENDSELECT      /*   Select for Screen colour   */
        CASE 2
         b:=ecsdiagnosis('What is the graphics problem?','Screen Breaks Up|Double Click Icons|No Sync|Bad Colour|No Video',0)
          SELECT b
                CASE 1
                 more:=ecsdiagnosis('SCREEN BREAKS up after 15-30 minutes:  Agnus, Denise\n          Agnus Socket Is Cracked','More|Quit',0)
                CASE 2
                 more:=ecsdiagnosis('SYSTEM LOCKS up when DOUBLE CLICKING on an icon:\n      Agnus, Denise, U7 8520 CIA(U300), U37 74LS32(U302)','More|Quit',0)
                CASE 3
                 more:=ecsdiagnosis('NO SYNCHRONIZATION:  Agnus, U41 74HCT245 (74HCT244(U205) on an A2000)','More|Quit',0)
                CASE 4
                 more:=ecsdiagnosis('BAD COLOURS:  Denise, Video Hybrid\n              U40-U41 74HCT245 (74HCT244(U205-U206) in an A2000)','More|Quit',0)
                CASE 0
                 more:=ecsdiagnosis('NO VIDEO(Black Screen):  R405,R406 4.7ohm Resistor, Denise\n          Video Hybrid, U40-U41 74HCT245 (74HCT244(U205-U206) in an A2000)','More|Quit',0)
          ENDSELECT
        CASE 3
         b:=ecsdiagnosis('What seems to be the problem:','No Printer|Bad Printer|Modem Send|Modem Receive',0)
          SELECT b
                CASE 1
                 more:=ecsdiagnosis('PRINTER won''t print:  U8 8520 CIA(U301), EMI 1501 47ohm Resistor(R318)','More|Quit',0)
                CASE 2
                 more:=ecsdiagnosis('PRINTER prints improperly:  U8 8520 CIA(U301)','More|Quit',0)
                CASE 3
                 more:=ecsdiagnosis('MODEM does not send:  1488 U38(U304), Paula, U8 8520 CIA(U301)','More|Quit',0)
                CASE 0
                 more:=ecsdiagnosis('MODEM does not receive:  1489 U39(U305), Paula, U8 8520 CIA(U301)','More|Quit',0)
          ENDSELECT
        CASE 4
         b:=ecsdiagnosis('What are the symptons of your mouse/joystick problem:','Mouse Doesn''t Move|Either Not Working|No LMB/Fire Button|No RMB',0)
          SELECT b
                CASE 1
                 more:=ecsdiagnosis('MOUSE doesn''t move:  Denise, 74LS157 U15(U202)\n               EMI 1401 5.1ohm Resistor\n               A2000 rev 6: F1 4amp Pico Fuse','More|Quit',0)
                CASE 2
                 more:=ecsdiagnosis('MOUSE or JOYSTICK not working:  74LS157 U15(U202), Denise, 74F04 U33(U107)','More|Quit',0)
                CASE 3
                 more:=ecsdiagnosis('No LMB or FIRE BUTTON:  U7 8520 CIA(U300)','More|Quit',0)
                CASE 0
                 more:=ecsdiagnosis('No RMB:  Paula','More|Quit',0)
          ENDSELECT
        CASE 5
         b:=ecsdiagnosis('What is the most accurate description of the drive problem:','Recognition|Motor|Disk Change|Write Protect|Read/Write|A2000 DF1:',0)
          SELECT b
                CASE 1
                 more:=ecsdiagnosis('Any DRIVE not recognized:  8520 CIA U8(U301), F3 or F4 4amp Pico Fuse','More|Quit',0)
                CASE 2
                 more:=ecsdiagnosis('MOTOR doesn''t work right:  8520 CIA U8(U301), Gary, 74LS38 U36(U203)','More|Quit',0)
                CASE 3
                 more:=ecsdiagnosis('Not recognizing DISK CHANGE:  8520 CIA U7(U300)','More|Quit',0)
                CASE 4
                 more:=ecsdiagnosis('WRITE PROTECT not recognized:  8520 CIA U7(U300)','More|Quit',0)
                CASE 5
                 more:=ecsdiagnosis('READ/WRITE errors:  Paula, M68000, Agnus','More|Quit',0)
                CASE 0
                 more:=ecsdiagnosis('A2000 DF1: not recognized:  8520 CIA U301, 74F00 U900, 74LS74 U108\n            J301 is OPEN(must be closed to recognize DF1:)','More|Quit',0)
          ENDSELECT
        CASE 6
         b:=ecsdiagnosis('Other problems may, or may not, be found here:','Audio|Keyboard Flashes|No Keyboard Reset|Other Keyboard',0)
          SELECT b
                CASE 1
                 more:=ecsdiagnosis('AUDIO problems may be caused by any of the following:\n        Paula\n        LF347/TL084 OP-amp U14(U204)\n        Q331 or Q321 FET(Q200 or Q201)\n        CN3 or CN4 Cold soldier connection(CN204 or CN205)\n        EMI 1303 or 1302(R243 or R233 1k ohm)\n        Or maybe just a bad external RCA cable?','More|Quit',0)
                CASE 2
                 more:=ecsdiagnosis('KEYBOARD flashes:\n     1 or 2 flashes is a bad 6570-036 controller\n     3 flashes is a bad 555/74ls123/74ls27','More|Quit',0)
                CASE 3
                 more:=ecsdiagnosis('No KEYBOARD RESET:  Q2(most likely), 74LS27','More|Quit',0)
                CASE 0
                 more:=ecsdiagnosis('If KEYBOARD is ok, check the following:\n        8520 CIA U7(U300)\n        Agnus\n        Gary\n        R914 1 ohm 1/2 watt resistor(A2000 only)','More|Quit',0)
          ENDSELECT
 ENDSELECT
UNTIL more=0
pw:=OpenW(80,50,400,70,$F,50,'Amiga Diagnostics ECS v1.0',NIL,1,NIL)
TextF(10,24,'© Encyclopedia Galactica 1994')
TextF(10,32,'zaph1@iastate.edu')
TextF(10,48,'Shareware registration $2')
TextF(10,56,'Buying it means using it :-)')
Delay(150)
CloseW(pw)
ENDPROC

PROC ecsdiagnosis(body,gadgets,args)
ENDPROC EasyRequestArgs(0,[20,0,0,body,gadgets],0,args)
