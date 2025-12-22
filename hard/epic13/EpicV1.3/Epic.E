/*
 * A serial mode PIC16C84 programmer © Stephen Marsden
 *
 *
 */

OPT OSVERSION=37

    /* Required Libraries */
MODULE 'tools/file'
MODULE 'tools/easygui'
MODULE 'asl', 'libraries/ASL'
MODULE 'amigalib/time'
MODULE 'resources/misc'
MODULE 'intuition/intuition'

    /* Parallel Port Data Bits */
CONST IN=0              -> Pin 2 
CONST OUT=0             -> Pin 2 
CONST CLK=1             -> Pin 3 
CONST RST=2             -> Pin 4 

    /* PIC16C84 Programming Commands */ 
CONST LDCONF=0          -> Load configuration
CONST LDPROG=2          -> Load data to Program Memory
CONST RDPROG=4          -> Read data from Program Memory (Verify)
CONST INCADD=6          -> Increment address counter
CONST BEGPRG=8          -> Begin programming
CONST LDDATA=3          -> Load data to Data Memory
CONST RDDATA=5          -> Read data from Data Memory (Verify)
CONST EPMODE=10         -> Enter parallel mode (Not used)

    /* Timing Requirements for Programming (in microseconds) */
CONST VPPDLY=200000     -> Time for programming voltage to settle
CONST PRGDLY=10000      -> Begin programming delay
CONST TSET=1            -> Data in setup time before clock low
CONST THLD=1            -> Data in hold time after clock
CONST TDLY=2            -> Delay between commands

    /* Memory Definitions */
CONST PROGRAM=0
CONST DATA=1
CONST PSIZE=1024        -> Program memory size
CONST DSIZE=64          -> Data memory size

    /* Configuration Fuses */
CONST CP=16             -> Code protection bit.  0=On, 1=Off
CONST PWRTE=8           -> Power-up timer bit.   0=Disabled, 1=Enabled
CONST WDTE=4            -> Watchdog timer bit.   0=Disabled, 1=Enabled
CONST RC=3              -> Resistor capacitor oscillator
CONST HS=2              -> High-speed crystal oscillator
CONST XT=1              -> Crystal oscillator
CONST LP=0              -> Power-saving, low-frequency crystal oscillator

    /* Intel Hex File-Formats */
CONST INHX16=1
CONST INHX8M=0

    /* Programming Speed */
CONST FAST=0
CONST SLOW=1

CONST NO_OP=$20         -> Fill byte used to clear program memory
CONST EOF=-1            -> End of file character
CONST TASKPRI=2         -> Increase task priority to maintain correct timing

    /* Global Program Variables */
DEF fuses
DEF oscillator=RC, cp=CP, wdt=0, pwrt=PWRTE     -> Default fuse settings
DEF prog_speed=SLOW

    /* File Handling Variables */
DEF progbuf[PSIZE]:ARRAY OF INT
DEF databuf[DSIZE]:ARRAY OF INT
DEF buffer[256]:ARRAY
DEF programfileStr[200]:STRING, datafileStr[200]:STRING
DEF fh, filename
DEF checksum            -> Check integrity of file
DEF hextype=INHX8M      -> Default file-type

    /* GUI Variables */
DEF gh=NIL:PTR TO guihandle
DEF programfileGad, datafileGad, progressgad, realgad:PTR TO gadget
DEF oscillatorGad, protectGad, wdtimerGad, pwrtimerGad
DEF win:PTR TO window

    /* Hardware Variables */
DEF hi=1                -> 1=Positive Logic, 0=Negative Logic
DEF lo=0                -> 0=Positive Logic, 1=Negative Logic
DEF port_bits=0         -> Temp. store for parallel port (only upper byte used)


PROC main() HANDLE              -> Turn on exception handling
DEF portowner=-1
DEF miscbase, my_task, oldtaskpri
    my_task:=FindTask(0)        -> Find pointer to current task.
    oldtaskpri:=SetTaskPri(my_task,TASKPRI) 
    IF (miscbase:=OpenResource('misc.resource'))=0 THEN Raise("MISC")
    portowner:='PIC_Programmer'
        MOVE.L  miscbase,A6     -> Takeover parallel port
        MOVE.L  portowner,A1
        MOVEQ   #MR_PARALLELPORT,D0
        JSR     MR_ALLOCMISCRESOURCE(A6)
        MOVE.L  D0,portowner
    IF portowner THEN Raise("PORT")

    setup()
    StrCopy(programfileStr,'.hex')      -> Default file name
    StrCopy(datafileStr,'.hex')
    JUMP start

CHAR '\0$VER: Epic 1.2 (24.01.97)\0'    -> For AmigaDOS 'version' command

start:
    IF myeasygui('Epic V1.2  © Copyright 1997 Stephen Marsden',
        [ROWS,
            [TEXT,'            PIC16C84 Microcontroller Programmer            ',NIL,FALSE,3],
            [COLS,
                [BEVEL,
                [ROWS,
                    [TEXT,'  Oscillator Type',NIL,FALSE,3],
                    oscillatorGad:=[MX,{changetype},NIL,['LP','XT','HS','RC',NIL],FALSE,oscillator]
                ]
                ],
                [ROWS,
                    [BEVEL,
                    [EQROWS,
                        [TEXT,'       Fuses',NIL,FALSE,3],
                        protectGad:=[CHECK,{protect},'Code Protection',Eor(cp,CP),FALSE],
                        wdtimerGad:=[CHECK,{wdtimer},'Watchdog Timer',wdt,FALSE],
                        pwrtimerGad:=[CHECK,{pwrtimer},'Power-up Timer',pwrt,FALSE],
                        [SPACE]
                    ]
                    ]
                ]
            ],
            [COLS,
                programfileGad:=[STR,{enter_program_str},' Program File',programfileStr,200,3],
                [BUTTON,{get_program_file},'Get']      
            ],
            [COLS,
                datafileGad:=[STR,{enter_data_str},' Data File',datafileStr,200,3],
                [BUTTON,{get_data_file},'Get']      
            ],
            [COLS,
                [CYCLE,{format},'Hex Format:',['INHX8M','INHX16',NIL],hextype],
                [CYCLE,{speed},'  Speed:',['Turbo','Normal',NIL],prog_speed]
            ],
            progressgad:=[TEXT,' ',NIL,TRUE,3],
            [BAR],
            [COLS,
                [BUTTON,{progmem},'Write Program'],
                [BUTTON,{verifymem},'Verify Program']
            ],
            [BAR],
            [COLS,
                [BUTTON,{progdata},'Write Data'],
                [BUTTON,{verifydata},'Verify Data'],
                [BUTTON,{config},'Blow Fuses']
            ]
        ]) THEN JUMP start
        
        
EXCEPT DO       -> Cleanup system on exit or fatal error
    SetTaskPri(my_task,oldtaskpri)      -> Task priority back to normal.
    IF portowner=NIL
        MOVE.L  miscbase,A6     -> Return parallel port to system
        MOVEQ   #MR_PARALLELPORT,D0
        JSR     MR_FREEMISCRESOURCE(A6)
    ENDIF
    SELECT exception
        CASE "MISC";    request('Could not open misc.resource!','Ok')
        CASE "PORT";    request('Parallel port already allocated to\n%s','Ok',[portowner])
        CASE "OPEN";    request('Could not open file!','Ok')
        CASE "IN";      request('Error reading file!','Ok')
        CASE "MEM";     request('Out of memory!','Ok')
        CASE "GUI";     request('Gui error!','Ok')
        CASE "GT";      request('Could not open gadtools.library','Ok')
        CASE "bigg";    request('Screen too small or font too big!','Ok')
        CASE "Egui";    request('Gui design error!','Ok')
    ENDSELECT
ENDPROC


    /* Load Program File Via Requester */
PROC get_program_file(info)
    filename:=requestfile('Select hex file')
    setstr(gh,programfileGad,filename)
    IF fh:=Open(filename,OLDFILE)
        loadhex(fh, progbuf, PSIZE)
        Close(fh)
    ELSE
    request('Could not open file!','Ok')
    filename:='.hex'
    setstr(gh,programfileGad,filename)
    ENDIF
ENDPROC


    /* Load Program File Via Entered Text */
PROC enter_program_str(info,str)
    filename:=str
    IF fh:=Open(filename,OLDFILE)
        loadhex(fh, progbuf, PSIZE)
        Close(fh)
    ELSE
    request('Could not open file!','Ok')
    filename:='.hex'
    setstr(gh,programfileGad,filename)
    ENDIF
ENDPROC


    /* Load Program File Via Requester */
PROC get_data_file(info)
    filename:=requestfile('Select hex file')
    setstr(gh,datafileGad,filename)
    IF fh:=Open(filename,OLDFILE)
        loadhex(fh, databuf, DSIZE)
        Close(fh)
    ELSE
    request('Could not open file!','Ok')
    filename:='.hex'
    setstr(gh,datafileGad,filename)
    ENDIF
ENDPROC


    /* Load Program File Via Entered Text */
PROC enter_data_str(info,str)
    filename:=str
    IF fh:=Open(filename,OLDFILE)
        loadhex(fh, databuf, DSIZE)
        Close(fh)
    ELSE
    request('Could not open file!','Ok')
    filename:='.hex'
    setstr(gh,datafileGad,filename)
    ENDIF
ENDPROC


    /* Configuration Changes Initiated By GUI */
PROC changetype(x,y) IS oscillator:=y
PROC protect(x,y) IS cp:=IF y THEN 0 ELSE CP
PROC wdtimer(x,y) IS wdt:=IF y THEN WDTE ELSE 0
PROC pwrtimer(x,y) IS pwrt:=IF y THEN PWRTE ELSE 0
PROC format(x,y) IS hextype:=IF y THEN INHX16 ELSE INHX8M
PROC speed(x,y) IS prog_speed:=IF y THEN SLOW ELSE FAST


    /* Change State Of CLK Line (not immediate) */
PROC clk(state) 
    IF state=1
        BSET.B  #CLK,port_bits      -> CLK=1
    ELSE
        BCLR.B  #CLK,port_bits      -> CLK=0
    ENDIF
ENDPROC


    /* Change State Of OUT Line (not immediate) */
PROC out(state) 
    IF state=1
        BSET.B  #OUT,port_bits      -> OUT=1
    ELSE
        BCLR.B  #OUT,port_bits      -> OUT=0
    ENDIF
ENDPROC


    /* Change State Of RST Line (immediate) */
PROC reset()
    BSET.B  #RST,port_bits
    assert()
    timeDelay(0,0,VPPDLY)
    BCLR.B  #RST,port_bits
    assert()
ENDPROC    


    /* Set State Of All Parallel Port Outputs (immediate) */
PROC assert()
    MOVE.B  port_bits,$BFE101
ENDPROC


    /* Check State of IN Bit (immediate) */
PROC inbit()
    MOVEQ   #0,D0
    BSET.B  #IN,D0
    AND.B   $BFE101,D0    
ENDPROC D0


    /* Inform Chip That We Are About To Program It */
PROC prog_mode()
    clk(lo)
    out(lo)
    reset()
    timeDelay(0,0,VPPDLY)
ENDPROC


    /* Setup CIA Hardware And Clear Memory Buffers */
PROC setup()
DEF i
        MOVE.W  #$7,D0         -> D0,D1,D2=Output mode
        MOVE.B  D0,$BFE301     -> CIA direction register        
    clk(lo)
    out(lo)
    assert()
        /* Clean buffers */
    FOR i:=0 TO PSIZE-1
        progbuf[i]:=NO_OP    -> Machine-code value for NO OPERAND
    ENDFOR
    FOR i:=0 TO DSIZE-1
        databuf[i]:=1
    ENDFOR
ENDPROC


    /* Send Data To Parallel Port */
PROC clock_out(bit)
    IF bit THEN out(hi) ELSE out(lo)
    clk(hi)
    assert()
    IF prog_speed THEN timeDelay(0,0,TSET)
    clk(lo)
    assert()
    IF prog_speed THEN timeDelay(0,0,THLD)
    out(lo)
    assert()
ENDPROC


    /* Read Data From Parallel Port */
PROC clock_in()
DEF b
    out(hi)
    clk(hi)
    assert()
    IF prog_speed THEN timeDelay(0,0,TSET)
    clk(lo)
    assert()
    b:=IF inbit() THEN hi ELSE lo
    IF prog_speed THEN timeDelay(0,0,THLD)
ENDPROC b


    /* Send Word To Chip */
PROC out_word(w)
DEF c
    clock_out(0)
    FOR c:=0 TO 13 DO clock_out(w AND Shl(1,c))
    clock_out(0)
ENDPROC


    /* Read Word From Chip */
PROC in_word()
DEF b, word
        MOVE.W  #$6,D0         -> D0=Input  D1,D2=Output
        MOVE.B  D0,$BFE301     -> CIA direction register         
    clock_in()
    word:=0
    FOR b:=0 TO 13 DO word:=word+Shl(clock_in(),b)
    clock_in()
        MOVE.W  #$7,D0         -> D0,D1,D2=Output
        MOVE.B  D0,$BFE301     -> CIA direction register             
ENDPROC word


    /* Send Command To Chip */
PROC command(cmd)
DEF b
    out(lo)
    assert()
    IF prog_speed THEN timeDelay(0,0,TDLY)
    FOR b:=0 TO 5 DO clock_out(cmd AND Shl(1,b) )
    out(hi)
    assert()
    IF prog_speed THEN timeDelay(0,0,TDLY)
ENDPROC


    /* Erase All Memory On Chip */
PROC erase()
DEF i
    prog_mode()
    command(LDCONF)
    out_word($3FFF)                     -> Disable code protection
    FOR i:=0 TO 6 DO command(INCADD)    -> Increment to fuse location $2007
    command(1)                          -> Undocumented command
    command(7)                          -> Undocumented command
    command(BEGPRG)
    timeDelay(0,0,PRGDLY)
    command(1)                          -> Repeat sequence
    command(7)
ENDPROC


    /* Display Progress Bar For User Feedback */
PROC progress(percentage)
DEF x1, y1, width, height
    IF percentage>100 THEN percentage:=100
    IF realgad:=findgadget(gh,progressgad)
        x1:=realgad.leftedge+2
        y1:=realgad.topedge+1
        width:=realgad.width-5
        height:=realgad.height-3
        Box(x1,y1,x1+(width*percentage/100),y1+height,3)
    ENDIF
ENDPROC


    /* Clear Progress Bar */
PROC clearprogress()
DEF x1, y1, width, height
    IF realgad:=findgadget(gh,progressgad)
        x1:=realgad.leftedge+2
        y1:=realgad.topedge+1
        width:=realgad.width-5
        height:=realgad.height-3
        Box(x1,y1,x1+width,y1+height,0)
    ENDIF
ENDPROC
        

PROC progmem() IS program(PROGRAM)
PROC progdata() IS program(DATA)


    /* Write to PROGRAM or DATA Memory on Chip */
PROC program(mem_type)
DEF i, n, w, mask, ldcmd, rdcmd, buf:PTR TO INT
    request('Make sure PIC is inserted correctly\nand placed in program mode i.e 12V','Continue')
    IF (mem_type=PROGRAM)
    erase()
        buf:=progbuf
        n:=PSIZE
        mask:=$3FFF
        ldcmd:=LDPROG
        rdcmd:=RDPROG
    ELSE 
        buf:=databuf
        n:=DSIZE
        mask:=$FF
        ldcmd:=LDDATA
        rdcmd:=RDDATA
    ENDIF
    clearprogress()
    prog_mode()
    FOR i:=0 TO n-1 
        command(ldcmd)
        out_word(buf[i])
        command(BEGPRG)
        timeDelay(0,0,PRGDLY)
        IF prog_speed
            command(rdcmd)
            w:=in_word() AND mask
            IF (buf[i] <> w)
                request('Write error during programming','Ok')
                RETURN
            ENDIF
        ENDIF
        command(INCADD)
        IF (i AND 2) THEN progress(i*100/(n-1))
    ENDFOR
ENDPROC


PROC verifymem() IS verify(PROGRAM)
PROC verifydata() IS verify(DATA)


    /* Verify Contents of PROGRAM or DATA Memory */
PROC verify(mem_type)
DEF i, n, w, mask, rdcmd, buf:PTR TO INT
    IF (mem_type = PROGRAM)
        buf:=progbuf
        n:=PSIZE
        mask:=$3FFF
        rdcmd:=RDPROG
    ELSE      
        buf:= databuf
        n:=DSIZE
        mask:=$FF
        rdcmd:=RDDATA
    ENDIF
    clearprogress()
    prog_mode()
    FOR i:=0 TO n-1 
        command(rdcmd)
        w:=in_word() AND mask
        IF (buf[i] <> w) 
            request('Verify failed','Ok')
            RETURN
      ENDIF
      command(INCADD)
        IF (i AND 2) THEN progress(i*100/(n-1))
    ENDFOR
ENDPROC


    /* Write Fuse Information To Chip */
PROC config()
DEF i
    fuses:=oscillator+cp+wdt+pwrt
    clearprogress()
    prog_mode()
    command(LDCONF)
    out_word(fuses)
    progress(20)
    FOR i:=0 TO 6 DO command(INCADD)
    progress(40)
    command(LDPROG)
    out_word(fuses)
    progress(60)
    command(BEGPRG)
    timeDelay(0,0,PRGDLY)
    progress(80)
    command(RDPROG)
    IF (fuses <> (in_word() AND $1F))
        request('Fuse failure','Ok')
        RETURN
    ENDIF
    progress(100)
ENDPROC


    /* Read A Single Hex Symbol From File */
PROC hexdigit(fp)
DEF c
    IF ((c:=FgetC(fp))=EOF) THEN Throw("HEX",'File error!\nUnexpected EOF in line')
    IF c>"9" THEN c:=c-"A"+10 ELSE c:=c-"0"
    IF (c<0 OR c>$F) THEN Throw("HEX",'File error!\nHex digit expected in line')
ENDPROC c


    /* Read Two Hex Symbols From File */
PROC hexbyte(fp)
DEF b
    b:=hexdigit(fp)
    b:=Shl(b,4) + hexdigit(fp)
    checksum:=checksum+b
ENDPROC b


    /* Read Four Hex Symbols From File */
PROC hexword(fp)
DEF w
    w:=hexbyte(fp)
    w:=Shl(w,8) + hexbyte(fp)
ENDPROC w


    /* Used During Loading/Converting Of Intel Hex Files */
PROC swab(w)
    MOVE.L  w,D0
    ROR.W   #8,D0       -> Swap upper and lower bytes of a word
ENDPROC D0


    /* Load An Intel Hex File */
PROC loadhex(fp, buf:PTR TO INT, bufsize) HANDLE
DEF type, nwords, i, address, w, line, bits
    type:=0
    line:=0
    WHILE (type<>1) 
        INC line
        IF (FgetC(fp)<>":") THEN Throw("HEX",'File error!\nError in line %ld\n":" Expected')
        checksum:=0
        w:=hexbyte(fp)
        nwords:=IF (hextype=INHX8M) THEN w/2 ELSE w
        w:=hexword(fp)
        address:=IF (hextype=INHX8M) THEN w/2 ELSE w
        type:=hexbyte(fp)
        IF address=$2008        -> Handle PARALLAX device info
            IF hexbyte(fp)<>1 THEN Throw("HEX",'Error!\nin line %ld\nFile has not been compiled for 16C84')
            hexbyte(fp)
            JUMP file_check
        ENDIF
        IF ((address>=$2000) AND (address<$2007))
            hexbyte(fp)         -> Handle PARALLAX ID info (ignored at present)
            hexbyte(fp)
            JUMP file_check
        ENDIF
        IF address=$2007        -> Handle PARALLAX fuse info
            bits:=hexbyte(fp)
            oscillator:=bits AND 3
            setmx(gh,oscillatorGad,oscillator)  -> Update fuse gadgets in GUI
            IF (bits AND 4)
                wdtimer(0,TRUE)
                setcheck(gh,wdtimerGad,TRUE)
            ELSE
                wdtimer(0,FALSE)
                setcheck(gh,wdtimerGad,FALSE)
            ENDIF
            IF (bits AND 8)
                pwrtimer(0,TRUE)
                setcheck(gh,pwrtimerGad,TRUE)
            ELSE
                pwrtimer(0,FALSE)
                setcheck(gh,pwrtimerGad,FALSE)
            ENDIF
            IF (bits AND 16)
                protect(0,FALSE)
                setcheck(gh,protectGad,FALSE)
            ELSE
                protect(0,TRUE)
                setcheck(gh,protectGad,TRUE)
            ENDIF
            hexbyte(fp)
            JUMP file_check
        ENDIF
        FOR i:=0 TO nwords-1 
            IF (address < bufsize)      -> Copy to PROGRAM buffer
                w:=hexword(fp)
                buf[address]:=IF (hextype = INHX8M) THEN swab(w) ELSE w
                INC address
            ELSEIF (address>=$2100) AND (address<$2140) -> Copy to DATA buffer
                w:=hexword(fp)
                databuf[address]:=IF (hextype = INHX8M) THEN swab(w) ELSE w
                INC address
                filename:='***Data Embedded In Program File***' -> Inform user
                setstr(gh,datafileGad,filename)
            ELSE
                Throw("HEX",'File error!\nImpossible address in line %ld')
            ENDIF
        ENDFOR
file_check:
        hexbyte(fp)
        IF FgetC(fp)=$0D THEN FgetC(fp)
        IF (checksum AND $FF) THEN Throw("HEX",'Checksum error!\nin line %ld')
    ENDWHILE
EXCEPT
    IF exception="HEX" THEN request(exceptioninfo,'Ok',[line]) ELSE ReThrow()
ENDPROC


/*    Presents an ASL load-file requester.  If the user selected a file,
      it is expanded to a full path-name */
PROC requestfile(title)
DEF fr:PTR TO filerequester
    IF aslbase:=OpenLibrary('asl.library',36)
        IF fr:=AllocAslRequest(ASL_FILEREQUEST,[ASLFR_TITLETEXT,title,0])
            IF AslRequest(fr,0)
                    /* strcpy() */
                MOVE.L  fr,A0
    	        MOVE.L  8(A0),A0    -> directory pointer from 'filerequester'
                MOVE.L  buffer,A1
np:             MOVE.B  (A0)+,(A1)+
                BNE.S   np
                AddPart(buffer,fr.file,256)
            ENDIF
            FreeAslRequest(fr)
        ENDIF
        CloseLibrary(aslbase)
    ENDIF
ENDPROC buffer


    /* Simple requester */
PROC request(body,gadgets,args=NIL)
ENDPROC EasyRequestArgs(0,[20,0,0,body,gadgets],0,args)


    /* Use global gui-handler (gh) instead of a local one */
PROC myeasygui(windowtitle,gui,info=NIL,screen=NIL,textattr=NIL) HANDLE
DEF res=-1
    gh:=guiinit(windowtitle,gui,info,screen,textattr)
    win:=gh.wnd
    WindowLimits(win,win.width,win.height,win.width,win.height)
    WHILE res<0
        Wait(gh.sig)
        res:=guimessage(gh)
    ENDWHILE
EXCEPT DO
    cleangui(gh)
    ReThrow()
ENDPROC res




