/* PowerOFF.rexx - switch the power of ATX power supply off in Amiga comuters equipped with AmigaATX */
/* $VER: PowerOFF.rexx 1.0 (2.02.2002) © 2002 by Michael Dmitriev <motorola_inside@mail.ru> */
/* This script will allow you to save unsaved data in the following programs: Wordworth; IBrowse, Voyager, AmFTP, AmIRC */

OPTIONS RESULTS

DO Num = 1 to 20
        WwPort = "WORDWORTH." || Num
        IF SHOW(PORTS, WwPort) THEN DO
                Address Value WwPort
                SAVE
		CLOSE
        END
END

IF SHOW(PORTS,WORDWORTH.1) THEN DO
        Address WORDWORTH.1 QUIT
END

Ports = "IBROWSE VOYAGER AMFTP.1 AMIRC.1"  /* Script will close these applications */

DO i = 1 TO WORDS(ports)
   IF SHOW('P', WORD(ports,i)) THEN 
   ADDRESS value WORD(ports,i)
   QUIT
END

Address 'COMMAND' 'C:RequestChoice Shutdown "Amiga will be switched off" OK CENTER'

Address 'COMMAND' 'C:POKE $BFD100 4'
