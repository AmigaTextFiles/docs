From megalith!errors@uunet.UU.NET Mon May 16 23:41:44 1994
Received: from relay3.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.5)
	id AA17999; Mon, 16 May 94 23:41:36 PDT
Received: from uucp5.uu.net by relay3.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AA12728; Tue, 17 May 94 02:41:27 -0400
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
        ; Tue, 17 May 1994 02:41:30 -0400
Received: by megalith.miami.fl.us (V1.16.20/w5, Dec 29 1993, 21:22:55)
	  id <1gnb@megalith.miami.fl.us>; Tue, 17 May 94 02:18:55 EDT -0400
Return-Path: <megalith.miami.fl.us!errors>
Sender: overlord@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: fnf@cygnus.com (Fred Fish)
Message-Number: 825
Newsgroups: comp.sys.amiga.announce
X-Newssoftware: CSAA NMS 1.2
Message-Id: <overlord.1gik@megalith.miami.fl.us>
Date: Tue, 17 May 1994 02:18:40 -0400 (EDT)
From: fnf@cygnus.com (Fred Fish) (CSAA)
To: announce@cs.ucdavis.edu (CSAA-Submissions)
Subject: Contents of May/June FreshFish CD
Status: R

				CONTENTS OF
		       May/June 1994 FreshFish CD-ROM

This file contains some overview information about the contents of this CD,
followed by list of one-line descriptions for each "product" for which
there is a Product-Info file.  Note that not all the material has a
corresponding product info file yet, so this list only describes a subset
of what is actually on this CD.

------------------------
STRUCTURE OF THIS CD-ROM
------------------------

The 650 Mb on this CD is divided into roughly three sections; (1) new
material, which includes newly released floppy disks as well as material
which does not appear in the floppy distribution, (2) useful utilities that
can be used directly off the CD if desired, thus saving 100 Mb or more of
hard disk space, and (3) older material from previously released floppy
disks or CD's.

The portion of the disk dedicated to new material that I've not previously
published on a CD or floppy disk is 241 Mb, broken down as follows:

   11 Mb   Archived (BBS ready) contents of floppy disks 976-1000.
   22 Mb   Unarchived (ready-to-run) contents of floppy disks 976-1000.

   82 Mb   Archived "new material" not included in floppy distribution.
  126 Mb   Unarchived "new material" not included in floppy distribution.

The portion of the disk dedicated to useful tools and other interesting
material that will be updated for each FreshFish CD is 383 Mb, broken down
as follows:

    6 Mb   Commodore includes, libs, and developer tools (V37-V40).
    6 Mb   Reviews of Amiga hardware, software, and other products.
   13 Mb   CD-ROM administration tools, documentation, etc.
   33 Mb   PasTeX source, fonts, and binaries.
   42 Mb   Miscellaneous useful tools, libraries, and examples.
   46 Mb   GNU binaries, libraries, and AmigaGuide info files.
   86 Mb   Archived (BBS ready) GNU source, binaries, libs & includes.
  151 Mb   Full GNU source code for supplied GNU executables.

The portion of the disk dedicated to old material is 26 Mb, broken down as
follows:

   17 Mb   Descriptions of contents of previous CD-ROM's & floppies.
    9 Mb   Archived (BBS ready) material from Mar/Apr FreshFish CD-ROM.

--------
GNU CODE
--------

Here are the current GNU distributions which are included in both source and
binary form.  In most cases, they are the very latest distributions ftp'd
directly from the FSF machines and compiled with the version of gcc included
on this CD-ROM.  I have personally compiled all of the GNU binaries supplied
on this CD-ROM, to verify that the compiler is solid and that the binaries
are in fact recreatable from the supplied source code.

bc-1.02		   find-3.8	      grep-2.0		 rcs-5.6.0.1
binutils-1.8.x	   flex-2.4.6	      groff-1.09	 sed-2.03
bison-1.22	   gas-1.38	      gzip-1.2.4	 shellutils-1.9.4
cpio-2.3	   gawk-2.15.4	      indent-1.9.1	 tar-1.11.2
dc-0.2		   gcc-2.3.3	      ispell-4.0	 termcap-1.2
diffutils-2.6	   gcc-2.5.8	      libg++-2.5.3	 texinfo-3.1
doschk-1.1	   gdb-4.12	      m4-1.1		 textutils-1.9
emacs-18.59	   gdbm-1.7.1	      make-3.70		 uuencode-1.0
f2c-1993.04.28	   ghostscript-2.6.1  patch-2.1
fileutils-3.9	   gmp-1.3.2	      perl-4.036

Here is an "ls -C" of the GNU binary directory which can be added to your
path to make these utilities usable directly off the CD-ROM, once it is
mounted:

[	    df		gdb	    ident	paste	    tee
addftinfo   diff	genclass    indent	patch	    test
afmtodit    diff3	geqn	    info	pathchk	    texi2dvi
ar	    dir		gindxbib    install	pfbtops	    texindex
as	    dirname	glookbib    ispell	pr	    tfmtodit
autoconf    doschk	gneqn	    ixconfig	printenv    touch
autoheader  du		gnroff	    ixtrace	printf	    tr
awk	    echo	gperf	    join	protoize    true
basename    egrep	gpic	    ksh		ps2ascii    unexpand
bc	    emacs	grefer	    ld		ps2epsi	    uniq
bdftops	    env		grep	    lkbib	psbb	    unprotoize
bison	    etags	grodvi	    ln		ranlib	    uudecode
c++	    expand	groff	    locate	rcs	    uuencode
cat	    expr	grog	    logname	rcsdiff	    v
chgrp	    f2c		grops	    look	rcsmerge    vdir
chmod	    false	grotty	    ls		rlog	    wc
chown	    fgrep	gs	    m4		rm	    who
ci	    find	gsbj	    make	rmdir	    whoami
cksum	    flex	gsdj	    makeinfo	sdiff	    xargs
cmp	    flex++	gslj	    merge	sed	    yes
co	    fold	gslp	    mkdir	sh	    zcat
comm	    font2c	gsnd	    mkfifo	size	    zcmp
cp	    g++		gsoelim	    mknod	sleep	    zdiff
cpio	    gawk	gtbl	    mt		sort	    zforce
csplit	    gcc		gtroff	    mv		split	    zgrep
cut	    gcc-2.3.3	gunzip	    nice	strip	    zmore
d	    gcc-2.5.8	gzexe	    nl		sum	    znew
date	    gccv	gzip	    nm		tac
dc	    gccv-2.3.3	head	    nroff	tail
dd	    gccv-2.5.8	id	    od		tar

----------------------
Other Useful Utilities
----------------------

Here is an "ls -C" of the Useful/Sys/C binary directory which can be added
to your path to make these utilities usable directly off the CD-ROM, once it
is mounted:

A-Kwic	     ExpungeXRef  LoadDB       PerfMeter    Viewtek	 flushlibs
AD2HT	     Flush	  LoadLibrary  Play	    Vim		 lha
ARTM	     History	  LoadXRef     PowerSnap    WDisplay	 look
AZap	     IView	  MKProto      RSys	    XIcon	 mg
AmigaGuide   Installer	  MakeAnim7    SD	    Xoper	 tapemon
Degrader     LHArc	  MuchMore     SnoopDos	    brik	 vt
DeviceLock   LHWarp	  NewZAP       SuperDuper   bsplit	 zoo
DiskSalv     Less	  PackIt       SysInfo	    chksum

---------------------
ONE-LINE DESCRIPTIONS
---------------------

This section is the output of running pitool to find all the product info
files on this CD-ROM and generate a one one discription for each product,
consisting of the name, version number, and the short description.  This
list is then sorted and piped to "uniq" to discard the duplicates for
material that appears more than once (such as in both the ready-to-run and
the BBS-ready sections).  The command which does this is:

    pitool -b -f - -F "%-22.22N %8.8V   %-40.40S\n" | sort | uniq

For further information about one of these products, use the KingFisher
or A-Kwic databases in the Tools directory.

PROGRAM			VERSION	  SHORT DESCRIPTION
--------------------    -------	  ---------------------------------------
A-Kwic                     2.00   Allows fast keyword search of text data 
ACE                         2.0   FreeWare Amiga BASIC compiler + extras  
ADAM_V3                       3   Calculates to 1000's of decimal places  
ADPro25PR                   2.5   ADPro 2.5 screenshots & press release   
AFile                      2.21   GUI-based datafile manager              
AGAiff                      1.0   An IFF-to-RAW converter                 
AGIndex                    1.04   Creates index for AmigaGuide document   
AII                         2.0   A GUI interface for most avail archivers
AMUC_Cover                  ?.?   Printable Cover for the AMUC CDRom      
APipe-Handler              37.5   Alternative pipe handler (incl. source) 
ARTM                        2.0   GUI-Based Real-Time System Monitor      
ARTM                       2.00   Display and control system activity     
ASC                        6.21   Amiga port of the UNIX spreadsheet SC   
ASwarmII                    2.0   Screenblanker Commodity, funny graphics 
AZap                       2.14   Binary editor for files, mem, or devices
AZap                       2.14   Binary file editor w/multiple buffers   
Accrete                     1.1   Create random star-systems, with planets
AcmaUtils                   ?.?   Misc useful CLI/script utilities        
AddPower                  37.14   Multi-Purpose OS Commodity              
AdmitOneHAM                 ?.?   HAM raytrace of TRex going to the movies
AdmitOneJPG                 ?.?   JPG raytrace of TRex going to the movies
Adrift                      ?.?   Ray traced 736x482 jpeg by Bill Graham. 
AlertPatch                  3.0   Supplies a lot more info during Alert() 
Alien3HAM                   ?.?   HAM raytrace of a profile of the Alien  
Alien3JPG                   ?.?   JPG raytrace of a profile of the Alien  
AlienBladder                ?.?   Ray traced 768x482 jpeg by Bill Graham. 
AlienHAM                    ?.?   HAM of raytraced Alien                  
AlienJPG                    ?.?   JPG of raytrace Alien                   
AmiCDROM                   1.10   ISO-9660 standard CDROM filesystem      
AmigaE                     2.1b   Amiga specific E compiler               
AmigaFAQ               94.01.28   "Frequently Asked Questions" about Amiga
AmigaGuide                 34.6   Commodore AmigaGuide hypertext utility  
Amortize                   1.16   Calculate loan amortizations/payments   
Anguish2HAM                 ?.?   HAM of a raytraced dragon and Earth     
Anguish2JPG                 ?.?   JPG of a raytrace dragon and Earth      
AnguishHAM                  ?.?   HAM raytraced dragon and moon           
AnguishJPG                  ?.?   JPG raytraced dragon and moon           
AntiCicloVir                2.1   Link/File/BB/Validator/Memory virus elim
Apple2000                   ?.?   Premier Apple ][ emulator for the Amiga 
Arachnid                    1.1   A game of patience using 2 card decks   
Aren                        1.2   An extension of the DOS Rename command  
Asplit                      2.0   Split large files into definable sizes  
AudioScope                  3.0   Realtime audio spectrum analyzer w/FFT  
Avarice2HAM                 ?.?   JPEG and HAM raytraced dragon closeup   
Avarice2JPG                 ?.?   JPEG raytraced dragon closeup           
AvariceHAM                  ?.?   HAM raytrace of dragon                  
AvariceJPG                  ?.?   JPEG raytrace of dragon                 
AwakeningHAM                ?.?   HAM raytrace, clean and well lit        
AwakeningJPG                ?.?   JPEG raytrace, clean and well lit       
BBBBS                       7.2   BaudBandit BBS, V7.2                    
BBDoors                     7.2   rexxDoor games and diversions for BBBBS 
BTNTape                     3.0   A "Better-Than-Nothing" scsi tape driver
BabySnakes                  ?.?   352x440x5 anim - 5 snakes slither around
BackupRexx                 1.10   ARexx script for daily system backups   
Banker                  2.0beta   Home accounting program w/MUI interface 
Banner                      1.5   Create banners from any font            
BattleHAM                   ?.?   HAM fight avarice VS firebreather       
BattleJPG                   ?.?   JPEG fight avarice VS firebreather      
Batworm                     ?.?   320x400x6 52 frame anim - winged worm   
Batworm                     ?.?   Ray traced 768x482 jpeg by Bill Graham. 
BeautifulBlueHAM            ?.?   768x482 HAM Imagine raytrace            
BeautifulBlueJPG            ?.?   768x482 HAM Imagine raytrace            
Bills_World                 ?.?   Ray traced 768x482 jpeg by Bill Graham. 
Bin2Hunk                    2.2   Create a linkable hunk from any file    
BioRhythm                   3.0   Shows your 3 basic BioRhythms & average 
BitART-City                 ?.?   Rendered scene of a future city.        
BitART-Toys                 ?.?   Rendered scene of a children's room     
BookLampHAM                 ?.?   384x482 HAM raytrace                    
BookLampJPG                 ?.?   768x482 JPEG raytrace                   
BootUte                     1.0   Allows more old pgms run on 1200/4000   
BootUte                     1.2   Enable older software on A1200/A4000    
BootWriter                  1.2   A bootblock installer with many features
Braids                      ?.?   Ray traced jpeg by Bill Graham.         
Brainship                   ?.?   Ray traced jpeg by Bill Graham.         
BreakName                  37.1   Send break to processes by filename     
Brik                        2.0   Compute & use CRC lists to verify files 
BrowserII                  2.41   Directory maintenance utility           
BumpyBalls                  ?.?   368x482x5 animation - flying balls      
Butterfly                   ?.?   Ray traced jpeg picture by Bill Graham. 
CDDA                        1.3   Play digital audio off Sony CD drives   
CFD-BladeRunner             ?.?   Rendered scene from Bladerunner movie   
CFD-Fantasy                 ?.?   704x566x24 JPEG virtual world scene     
CFD-ModernRoom              ?.?   704x566x24 JPEG virtual world scene     
CFD-ThreeCans               ?.?   352x566x6 HAM raytrace of softdrink cans
CFD-TwoCans                 ?.?   352x566x6 HAM raytrace of softdrink cans
CLIExchange                 1.4   A CLI version of standard Exchange util 
CManual                     3.0   Amiga programming documents and examples
CVTS                        1.0   The Complete Video Test System          
Calc                       v2.0   An RPN calculator with a stack window   
Candy1                      ?.?   Ray traced jpeg picture by Bill Graham. 
Candy2                      ?.?   Ray traced jpeg picture by Bill Graham. 
CapsLockExt                 1.0   Extends CapsLock to ALL keys            
CaptainNed                  ?.?   Ray traced jpeg picture by Bill Graham. 
CarCosts                   3.03   Keep track of automobile expenses       
CasioLink                   1.0   Amiga to Casio FX-850P data link        
CastlRok                    ?.?   Imagine rendered picture                
CatEdit                    1.1a   A GUI catalog editor/translator         
CatEdit                    1.1b   A GUI catalog editor/translator         
Chamber                     ?.?   Ray traced jpeg picture by Bill Graham. 
ChangeIcon                  1.0   Give files specified icon, uses WhatIs  
CharMap                     1.0   2-Color selectable font ILBM2ASCII util 
CheckMateHAM                ?.?   HAM raytrace of a twisted chess board   
CheckMateJPG                ?.?   JPEG raytrace of a twisted chess board  
Chimera2HAM                 ?.?   HAM trace, dragon over mystic sea       
Chimera2JPG                 ?.?   JPEG trace, dragon over mystic sea      
ChimeraHAM                  ?.?   HAM raytrace of dragon in jungle        
ChimeraJPG                  ?.?   JPEG raytrace of dragon in jungle       
CliVa                       2.3   A VERY configurable Application launcher
ClickNot                   37.3   Stop your disk drives from clicking     
ClipHistory                 1.0   Adds a history to the clipboard device  
ClockTool                   1.1   Manipulate battery and/or system clocks 
Clouds                      3.1   Creates random cloud images             
CloudsAGA                  1.01   Creates random clouds in AGA resolutions
ColConq                    1.05   Space strategy game for 1 or 2 persons  
ConPaste                  37.25   Commodity to paste clipped text anywhere
CopColEd                    1.2   Programmers Copper color editor         
Crossing                    ?.?   Ray traced jpeg picture by Bill Graham. 
Csh                        5.37   Replacement for the shell, like UN*X csh
CyberPager                  1.4   Send alpha-numeric messages to pagers.  
Cyber_Express               ?.?   746x484x24 cybernetic expressions poster
DBB                       1.1.9   DBB is a digital logic circuit simulator
DCmp                       1.52   Compare two disks byte by byte          
DFA                         2.0   Address database with many features     
DMS                        1.11   A popular disk archiver                 
DQua                       1.00   GUI-based Quadratic equation solver     
Dandelion                   ?.?   Ray traced jpeg picture by Bill Graham. 
Degrader                   1.30   Tries to get badly written progs to work
DeliTracker                2.01   Flexible soundplayer for many formats   
Delivrance                  ?.?   JPEG of raytraced surealistic picture   
DeviceGuide                 1.0   AmigaGuide list/desc of common .devices 
DeviceLock                  1.1   GUI interface for CLI command 'lock'    
DeviceLock                  1.2   GUI interface for CLI command 'lock'    
DiceConfig                  2.0   GUI based frontend for Dice C compiler  
DirKING                    3.00   Powerful 'List' and 'Dir' replacement   
DiskCat                     2.1   A configurable disk librarian           
DiskInfoTools               1.0   Three useful disk information tools     
DiskMon                    2.6t   Disk monitor - for most block devices   
DiskSalv2                 11.27   Disk repair, salvage, and undelete util 
DiskSalv2                 11.30   Disk repair, salvage, and undelete util 
DragonDreams2HAM            ?.?   HAM raytraced dragon                    
DragonDreams2JPG            ?.?   JPEG raytraced dragon                   
DragonDreamsHAM             ?.?   768x482 HAM Imagine rendered picture    
DragonDreamsJPG             ?.?   768x482 JPEG Imagine rendered picture   
DragonSongHAM               ?.?   HAM Lightwave 3.0 dragon anim frame     
DragonSongJPG               ?.?   JPEG Lightwave 3.0 dragon anim frame    
Drip                        ?.?   384x482x6 42 frame anim - water drops   
DropBox                     1.1   Source for (yet unreleased) DropBox v1.1
Duerer                     1.01   A simple GeoPaint like paint program    
DviDvi                      1.1   Modify the contents of a dvi file       
ECopy                      1.10   Copy files from HD to min # of floppies 
EggFry                      ?.?   160x200x6 62 frame anim - 2 eggs frying 
EmbraceHAM                  ?.?   HAM raytrace of a loving embrace        
EmbraceJPG                  ?.?   JPEG raytrace of a loving embrace       
EmeraldHAM                  ?.?   HAM raytrace of dragon on Emerald Isle  
EmeraldJPG                  ?.?   JPEG raytrace of dragon on Emerald Isle 
Enforcer                  37.55   Monitor for illegal memory accesses     
Enforcer                  37.60   Tool to monitor illegal memory access.  
Escape                      ?.?   Ray traced jpeg picture by Bill Graham. 
FDB                         1.3   Quickly locate files/dirs with database.
FDPro2Demo                  2.0   Very realistic flight simulator         
FINANCA                     1.4   Calculate MORTGAGES, ANNUITIES, INTEREST
FastJPEG                   1.10   JPEG viewer, both fast and good quality.
FastLife                    2.7   Conway's Life game with 200+ patterns   
Filer                      3.14   Configurable GUI-based Directory Utility
Find                        2.3   A tool for searching disk partitions    
Fingercows                  ?.?   Ray traced jpeg picture by Bill Graham. 
FireBreatherHAM             ?.?   HAM raytrace of fire breathing dragon   
FireBreatherJPG             ?.?   JPEG raytrace of a fire breathing dragon
FishRachel                  1.0   Cartoon picture for use as WB backdrop. 
Flat                        1.3   Handler for block-mapped filing devices 
Fleuch                      3.0   Scrolling, shoot-em-up, gravity game    
FlexCat                     1.2   Creates catalogs & source to handle them
FlipIt                      1.0   Flip through screens via hotkeys.       
FlipIt                      1.1   Flip through screens via hotkeys.       
Flush                       1.2   Flushes unused libs, devices, and fonts 
FollowMe                    ?.?   384x482x6 86 frame anim - bouncing ball 
ForceIcon                   1.2   Forces Disk.info to position/image      
ForceIcon                   1.4   Substitute Icon images and positions    
Forth                       ?.?   Forth Programming language              
Forth                       ?.?   Forth Programming language
FruitAnim                   ?.?   368x482x6 152 frame anim, morphing fruit
FunkyBike                   ?.?   704x482x24 raytraced pic of a motorcycle
GEDScripts                  1.1   Some useful ARexx scripts for GoldED    
GNU-Startup                 1.0   Script and files to setup GNU environ.  
Gardenwalk                  ?.?   Ray traced jpeg picture by Bill Graham. 
Genie                      2.56   A GUI based genealogy data manager      
Gladiator                   1.0   Arena combat wargame, runs in WB window 
GotaAnim                    ?.?   Anim of a falling drop of water         
GreatWhiteHAM               ?.?   HAM raytrace of great white shark       
GreatWhiteJPG               ?.?   JPEG raytrace of great white shark      
GreenPeril                  ?.?   160x100x6 127 frame anim - tyranny peril
Guardian                    ?.?   Ray traced jpeg picture by Bill Graham. 
GutterWarHAM                ?.?   HAM raytraced spider and scorpion       
GutterWarJPG                ?.?   JPEG raytraced spider and scorpion      
HD_Frequency             38.051   Record sound samples to hard drive      
HD_Frequency             38.076   Record sound samples to hard drive      
HQMM                       1.14   MapMaker for Hero Quest                 
HWGRCS                   5.6pl8   GNU Revision Control Sys 5.6pl8 (1 of 3)
HWGRCS                   5.6pl8   GNU Revision Control Sys 5.6pl8 (2 of 3)
HWGRCS                   5.6pl8   GNU Revision Control Sys 5.6pl8 (3 of 3)
HandlerGuide                1.0   AmigaGuide list/desc of common handlers 
Harridan                    1.0   Simple "Reminder" type utility          
Heads                       ?.?   Ray traced jpeg picture by Bill Graham. 
HellSpawnHAM                ?.?   768x482 HAM Imagine raytrace            
HellSpawnJPG                ?.?   768x482 JPEG Imagine raytrace           
Hinge                       ?.?   160x200x6 102 f. anim - concentric rings
History                    37.5   List and control shell command history. 
HubblePics                  ?.?   Misc pictures from Hubble project       
HuntHAM                     ?.?   HAM 3D T. Rex night hunting             
HuntJPG                     ?.?   JPEG 3D T. Rex night hunting            
HuntWindows                 3.3   Finds active window on oversize screens 
Hydra                       1.0   A bidirectional file transfer protocol  
ILBMKiller                  1.0   An IFF/AGA ILBM file viewer w/delete    
IRMaster                    2.2   Replace IR remote controls with Amiga.  
ITF                        1.46   Infocom data file interpreter           
IceAgeHAM                   ?.?   HAM raytraced dinosaurs and icebergs    
IceAgeJPG                   ?.?   JPEG raytraced dinosaurs and iceburgs   
IceCube                     ?.?   160x200x6 77 frame anim, melting icecube
IconMonger                  2.0   Make global changes to icons            
IconToClip                  1.0   Copies icon name to clipboard           
Iconian                   1.90_   Icon editor using OS 3.x & AGA features.
Iconian                   1.97_   Icon editor that supports OS3.0 funcs.  
ImagemsDemo                 ?.?   Slide geometric pieces into proper place
Imploder                    4.0   Reduce executable size using compression
Installer                  1.26   Commodore's Amiga Installer utility     
Jade                        3.0   Programmer's editor Amiga and Unix X11  
JellyBoxes                  ?.?   384x482x6 102 frame anim, rotating cubes
JoyRide                     1.0   Intuition front-end for joystick events.
JukeBox                  1.2530   GUI-based audio CDROM disk player       
Jumble                      ?.?   Ray traced jpeg picture by Bill Graham. 
KMI                         ?.?   Some more 8-color MagicWB Icons         
Kalender                    2.1   A small calendar program                
KeysPlease                  1.3   Get RAWKEYs and ASCII codes with GUI    
KingCON                     1.2   Useful replacement to CON: and RAW: devs
KingFisher                2.0_9   Aminet/FishDisk/CD-ROM Catalog Tool,BETA
KissHAM                     ?.?   HAM raytraced closeup of Alien          
KissJPG                     ?.?   JPEG raytraced closeup of Alien         
KnowledgeHAM                ?.?   HAM of an abstract raytrace             
KnowledgeJPG                ?.?   JPEG of an abstract raytrace            
LHArc                      1.30   Archive program using LZHUF compression 
LHWarp                     1.40   Disk packer for .lhw files              
Lens                        ?.?   384x482x6 102 frame anim, moving lense  
Less                       1.6Z   Amiga port of UNIX text file reader     
LhA                        1.38   A fast LhArc compatible archiver        
LhSFX                       1.5   Creates self-extracting Lh archives.    
LibraryGuide                1.1   AmigaGuide list/desc of common libraries
LibraryGuide                1.4   AmigaGuide list/desc of common libraries
Lilypond                    ?.?   Ray traced jpeg picture by Bill Graham. 
Lines                       2.2   A simple game to draw lines             
Lines                       2.2   OS friendly line drawing game           
Lines                       2.4   OS friendly game where you draw lines.  
LivingRoomHAM               ?.?   HAM of raytraced livingroom             
LivingRoomJPG               ?.?   JPEG of raytraced livingroom            
LoanCalc                    2.0   A mortgage/loan calculation utility     
Lurker                      ?.?   Ray traced jpeg picture by Bill Graham. 
MCalc                       1.2   A MUI-based calculator                  
MCalc                       1.3   A powerful MUI-based calculator.        
MMBCommodity                1.0   Define actions for middle mouse button  
MPatch                     37.4   Inspect various properties of a monitor 
MSplit                      1.3   Multi-Platform split/join file utility  
MTool                      2.0a   Directory utility resembling DMaster.   
MUI                         2.0   Object oriented graphical user interface
MUIFFR                      1.1   GUI for selecting files of Fidonet boxes
MainActor                  1.23   Modular animation package               
MakeCat                   38.02   Makes creating locale catalog files easy
Man                         1.9   A simple MAN cmd, recognizes guide files
Man                       1.11a   Unix type Man command                   
Mand2000D                 1.200   Demo of a revolutionary fractal program 
MannyManta                  ?.?   384x482x6 102 frame anim - swimming ray 
Marbles                     ?.?   Ray traced jpeg picture by Bill Graham. 
MasterMind                  1.6   An interesting game of guess the colors 
MeMon                       1.1   Dec/HEX/bin/ASCII conv & mem monitor    
MeMon                       1.1   Dec/HEX/bin/ASCII converter/mem-monitor.
Medieval_Castle_1           ?.?   1280x1024x24 JPEG trace, medieval castle
Medieval_Castle_1           ?.?   896x628x8 HAM raytrace, medieval castle 
Medieval_Castle_2           ?.?   1280x1024x24 JPEG trace, medieval castle
Medieval_Castle_2           ?.?   896x628x8 HAM raytrace, medieval castle 
MegaBall                    3.0   Amiga action game with AGA support.     
MegaPteraHAM                ?.?   HAM raytrace of humpback whale          
MegaPteraJPG                ?.?   JPEG raytrace of a humpback whale       
MemClear                    1.8   Fill unused memory with selected byte   
Metalpuddle                 ?.?   Ray traced jpeg picture by Bill Graham. 
MineSweeper                 1.1   Another feature-filled "Mines" type game
MiserPrint                 1.11   Print util for HP-Deskets and compatible
MonitorInfo                37.4   Inspect various properties of a monitor 
Montana                     1.2   Solitaire card game for the WorkBench   
Moodswing                   ?.?   Ray traced jpeg picture by Bill Graham. 
Morph                       ?.?   160x200x6 302 frame anim - morphing objt
Morph2                      ?.?   384x482x6 153 frame anim - morphing objt
Morph3                      ?.?   384x482x6 102 frame anim - morphing objt
Morph3                      ?.?   384x482x6 102 frame anim - morphing objt
Morph4                      ?.?   384x482x5 132 frame anim - donut bulge  
MouseAideDEMO             9.81a   Extremely versatile mouse utility       
MouseClock                 1.22   Battery backed-up clock/calendar project
Move                        1.8   UNIX style move command                 
Move                       1.10   Unix type Move command                  
MuchMore                    4.3   Soft scroll text viewer with xpk-support
MungWall                  37.64   Watches for illegal FreeMem's           
NDUK                         37   Partial CBM Native Developer Update Kit 
NDUK                         39   Partial CBM Native Developer Update Kit 
NDUK                         40   Partial CBM Native Developer Update Kit 
NDUK include files           40   Amiga include files for gcc binary tree.
NDUK libraries               40   Amiga libraries for gcc binary tree.    
NewArrival                  ?.?   Ray traced jpeg picture by Bill Graham. 
NewEdit                     1.8   Adds new edit functions to string gads  
NewExt                      1.0   Replaces or removes file extensions     
NewIFF                    39.11   New IFF code modules and examples       
NewTool                     2.6   Replace default tool in project icons.  
NewZAP                      3.3   Multipurpose file sector editing utility
NghtPrey                    ?.?   JPEG raytrace, Imagine rendered picture 
NghtWind                    ?.?   JPEG raytrace, Imagine rendered picture 
Oddjob                      ?.?   Ray traced jpeg picture by Bill Graham. 
Oinker                      ?.?   384x241x3 57 frame anim - feeding pigs  
OnTheBall                  1.20   Demo version of a desktop aid program   
OrcaHAM                     ?.?   HAM raytrace, killer whales & coral reef
OrcaJPG                     ?.?   JPEG raytrace, killer whales, coral reef
PARex                      3.10   Text filter/converter/utility           
PGS3Preview                 3.0   Preview and screenshots of PageStream 3 
PICS3D                      ?.?   8 3D pictures for DCTV and Xspecs-3D    
PackIt                   37.110   CLI only PowerPacker cruncher/decruncher
ParM                        4.5   Create menus to run your favorite tools 
ParasaurHAM                 ?.?   HAM 3D Lightwave 3.0, parasaurolophus   
ParasaurJPG                 ?.?   JPEG 3D Lightwave 3.0, parasaurolophus  
ParfumBttls                 ?.?   Ray traced jpeg picture by Bill Graham. 
PasTeX                      1.3   Port of TeX, powerful typesetting system
PerfMeter                   2.2   CPU usage, load and memory meter        
PhoneDir                    2.0   Personal Phone Directory                
PicCon                     2.01   Image converter for programmers.        
PicCon                     2.20   Image Conversion utility for programmers
PicIcon                    1.03   Create icons from IFF ILBM pictures     
Pinkscape                   ?.?   Ray traced jpeg picture by Bill Graham. 
PlayCDDA                    1.1   Play CD's over the Amiga's audio device 
PleasureHAM                 ?.?   HAM Lightwave 2.0 3D rendering          
PleasureJPG                 ?.?   JPEG Lightwave 3.0 3D rendering         
Pods                        ?.?   Ray traced jpeg picture by Bill Graham. 
PolyFit                    1.21   "Method of least squares" line fitting  
PoolRachel                  1.0   Cartoon picture for use as WB backdrop  
PowerCache               37.115   Flexible and Powerful Disk Caching Sys  
PowerCalc                  1.50   Optimized WB 2D graphing calculator     
PowerHAM                    ?.?   HAM raytrace of a floating female       
PowerJPG                    ?.?   JPEG raytrace of a floating female      
PowerSnap                  2.2a   Commodity to cut and paste text         
PrtSc                      1.75   Utilize PrtSc key for screen/file dump  
Pulse                       ?.?   160x100x6 252 frame anim - thorny sphere
QDisk                      2.10   WorkBench utility to monitor space usage
QMouse                     2.90   Small multi-functional mouse utility    
QuadraComp                 2.03   Protracker and EMOD music tracker       
RDS                         2.1   Single Image Random Dot Stereogram genr.
RKRM                        ?.?   Source and executables from 3rd ed. RKM 
RSys                        1.3   Very comprehensive system monitor       
RachelMascot                1.0   Cartoon picture for use as WB backdrop  
RachelValley                1.0   Cartoon picture for use as WB backdrop  
ReadmeMaster                2.0   Keyword data base of AmigaLibDisks 1-975
Recall                      2.2   Utility to help you remember events     
Replex                      2.0   OS Patch to use substitute tools        
ReqChange                   3.1   Makes system use Reqtools requesters    
ReqTools                    2.2   Very useful shared requester library    
ReqTools                   2.2b   Very useful shared requester library    
Ride                        ?.?   352x220x4 327 frame anim - objt on belt 
RippleCube                  ?.?   384x482x6 152 frame anim - rotating cube
RippleGrey                  ?.?   320x200x4 402 frame anim - rotating cube
Road2Nowhere                ?.?   752x480x24 JPEG raytrace, abrupt ending 
RoundCandy                  ?.?   384x482x6 62 frame anim - dancing candy 
RunePort                    ?.?   Ray traced jpeg picture by Bill Graham. 
RunnerAnim                  ?.?   R3D v2.4 example anim of running legs   
RushDemo2               37.5370   Full-featured directory utility demo    
S-Pack                      1.1   Archiver w/multivol, selfextract, & more
SCDPlayer                   1.1   Very small CDPlayer commodity w/source  
SCR                        1.01   AGA Screen Color Requester              
SCS                         1.0   Cricket (darts) scoring utility.        
SCSIutil                   2.02   Do low-level operations on a SCSI dev.  
SIRDS_GEN                   3.4   Single Image Random Dot Stereogram genr.
SOI                        1.2B   A strategy game of galactic colonization
SSearch                     1.3   Fast replacement for AmigaDOS 'search'  
SSplit                      1.3   Split large files in smaller ones       
ScreenSelect                2.2   Change screen order with listview       
SeaGlow                     ?.?   Ray traced jpeg picture by Bill Graham. 
SeaLifeHAM                  ?.?   HAM raytraces, dolphin & whale          
SeaLifeJPG                  ?.?   JPEG raytraces, dolphin & whale         
SeaSnouts                   ?.?   Ray traced jpeg picture by Bill Graham. 
SetPatch                  40.14   Utilities to patch AmigaDOS 2.04 - 3.1  
SillyPutty                  ?.?   320x400x5 152 frame anim - ball of putty
Simulator                   ?.?   JPEG, Flight Simulator, Delft Markt Sq. 
SmallPlayer                1.0a   Small module player                     
SmartCache                1.77a   Floppy disk caching program             
SnakeRoom                   ?.?   Ray traced jpeg picture by Bill Graham. 
SnoopDOS                    1.7   Monitors calls to AmigaDOS functions    
SnoopLibs                   0.9   Library function-call monitor           
Snoopy                      2.0   Monitor calls to library/devs/resources 
Sort                       1.23   CLI-based ascii text file sort utility  
SpaceCheezeBurger           ?.?   384x482x6 101 frame anim - wierd burger 
SpaceDragon                 ?.?   Ray traced jpeg picture by Bill Graham. 
SpaceScape                  ?.?   352x440x6 IFF raytrace view of Jupiter  
SpeakTimeCX                 1.2   Have the system time spoken by hotkey   
Spellbound                  ?.?   Ray traced jpeg picture by Bill Graham. 
Spinners                    ?.?   Ray traced jpeg picture by Bill Graham. 
Sploin                     1.70   Multi-platform split/join file utility  
StartUp-Menu               1.00   Customizable startup utility            
StartWindow                 ?.?   Launch applications from WB zipwindow   
Stocks                    3.04a   Comprehensive stocks analysis program.  
StrangeBrew                 ?.?   Ray traced jpeg picture by Bill Graham. 
StripANSI2                  ?.?   Strip ANSI Sequences from a file        
SummaDriver                2.01   Driver for Summagraphic digitizer tablet
Summertime                  ?.?   Ray traced jpeg picture by Bill Graham. 
SunSetHAM                   ?.?   JPEG whale anim frame with particles    
SunSetJPG                   ?.?   JPEG whale anim frame with particles    
SunWindows              2.0.030   A virtual screen/window manager         
SuperDark                   2.0   A very nice modular screen blanker      
SuperDark                  2.0a   A very nice modular screen blanker      
SuperDuper                  3.0   Very fast disk copier and formatter     
SuperDuper                  3.1   High-speed disk copier and formatter    
SuperView                   2.1   Graphics Viewer/Converter/ScreenGrabber 
SuperViewLib                3.6   Lib for graphics loading/saving/display 
Sushi                     37.10   Intercept and display output of KPrintf 
SwazInfo                    1.0   Replaces WorkBench information window   
SysInfo                    3.24   Gives comprehensive system information  
T2Cow                       ?.?   Ray traced jpeg picture by Bill Graham. 
TWA                         1.4   Remembers last active window on any scr 
Tadpoles                    ?.?   Ray traced jpeg picture by Bill Graham. 
Tako                        ?.?   Ray traced jpeg picture by Bill Graham. 
TakoI                       ?.?   208x400x6 152 frame anim - skull & more 
Tall_Ships_Passage          ?.?   1025x768x8 GIF of raytrace from anim    
Tall_Ships_Passage          ?.?   896x628x8 HAM raytrace from anim        
TauIcons                    1.5   Third release of MagicWB style icons    
TempleFINALHAM              ?.?   HAM final traced temple scene           
TempleFINALJPG              ?.?   JPEG final traced temple scene          
TempleHAM                   ?.?   HAM raytraced temple scene              
TempleJPG                   ?.?   JPEG raytraced temple scene             
TexPrt                      3.0   Front-end for DVI printer drivers       
Text2Guide                 3.01   Convert ASCII text to AmigaGuide format.
ThanksGiving92              ?.?   160x200x6 101 frme anim, morphing turkey
TheGuru                     2.3   Explain specific GURU numbers.          
Throneroom                  ?.?   Ray traced jpeg picture by Bill Graham. 
ThunderHAM                  ?.?   HAM 3D raytrace of Tyrannosaurus Rex    
ThunderJPG                  ?.?   JPEG 3D raytrace of Tyrannosaurus Rex   
Tigership                   ?.?   Ray traced jpeg picture by Bill Graham. 
TimelessEmpire              1.1   Interactive non-graphical fiction game  
TitleClock                  3.3   Configurable clock hides in title bar   
TongueMonster               ?.?   160x225x6 81 frame anim - frog monster  
TongueMonster               ?.?   Ray traced jpeg picture by Bill Graham. 
ToolType                 37.210   Edit ToolTypes easily.                  
ToolType                 37.210   Edit tooltypes in icon with text editor 
Touch                       1.3   Unix type Touch command                 
Transit                     ?.?   160x200x6 127 frame anim - fly through  
TrickOrTreat                ?.?   208x250x6 119 frame anim, Jack-O-Lantern
TrickOrTreat                ?.?   Ray traced jpeg picture by Bill Graham. 
TurboCalc                   2.0   Demo version of powerful spreadsheet    
Twisted_City                ?.?   1280x1024x24 JPEG pic of a twisted city 
Twisted_City                ?.?   896x628x8 HAM pic of a twisted city     
Tyrell                      ?.?   JPEG Imagine rendered bladerunner pic   
UChess                     2.71   Nicely done Amiga port of GNU chess     
UChess                     2.78   Amiga port of GNU chess (part 1 of 2).  
UChess                     2.78   Amiga port of GNU chess (part 2 of 2).  
UChess                     2.83   Nicely done Amiga port of GNU chess     
Usage                      1.06   Extended "du" (disk usage) type command 
VCLI                       7.04   Control CLI by voice commands           
Val                         2.3   A disk partition validator (OFS or FFS) 
Verbes                      1.1   A program to help practice French verbs 
VideoMaxe                  4.33   A video database for private video users
VideoTitler                1.15   Create Title/Credits for your own video 
Viewtek                     2.1   Feature packed picture/animation viewer 
Viewtek                 2.1.378   Feature packed picture/animation viewer 
Vim                         2.0   A clone of the UNIX "vi" text editor    
VirusChecker               6.41   A memory/file/bootblock virus detector  
VirusZ                 rel II v   Popular boot and file virus detector    
VirusZII                   1.03   AntiVirus utility with file decrunching 
VirusZII                   1.07   AntiVirus utility with file decrunching 
Visitation                  ?.?   Ray traced jpeg picture by Bill Graham. 
VoiceShell                 1.21   Control your Amiga with voice commands. 
WB2Stuff                    ?.?   WB2 icons, presets, and IFF Images.     
WBFlash                     2.1   Color-cycle active window or WorkBench  
WBrain                    v2.1a   A thinking game for the WorkBench       
Wacom                      1.10   Wacom tablet driver, controls Amigamouse
WarpoTheClown               ?.?   240x300x6 101 frame anim - clown head   
Washer                      ?.?   An essential screen maintenance utility 
WavesHam                    ?.?   HAM Anim of Soothing Twilight Waves     
Wbsm                        1.2   Enable/Disable WBStartup progs at boot  
WhatIs                      3.5   Can detect file types                   
WhatIs                      4.0   Shared lib that recognizes file types   
WhereK                      9.8   A configurable hard drive utility       
Wiggle                      ?.?   320x400x6 53 frame anim - skull & tongue
WindowDaemon                1.6   Extended control to intuition windows   
WormBall                    ?.?   208x250x6 76 frame anim - ball+tentacles
XFD                        1.00   Utilities/shared library for decrunching
Xoper                       2.4   Monitor and control system activity     
XprKermit                  2.35   XPR-compatible file transfer protocol   
YADCP                       1.1   Yet Another CD Player                   
Yass                        2.0   Yet another Screen Selector Commodity   
Zap                        2.44   Binary file editor w/pub screen support 
Zapper                      ?.?   384x482x5 152 fr. anim - lightening ball
bBaseII                     5.6   Easily stores and retrieves information.
bBaseIII                   1.43   Full-Featured database program          
bash                     1.13.4   GNU Bourne Again SHell - Amiga diffs    
bash                     1.13.5   GNU Bourne Again SHell - orig FSF source
bc                         1.02   GNU Calculator language - Amiga binary  
bc                         1.02   GNU Calculator language - Amiga src+diff
bc                         1.02   GNU Calculator language - orig FSF src  
binutils                    1.9   Binary file utilities - orig FSF source.
binutils                  1.8.x   Binary file utilities - Amiga binaries  
binutils                  1.8.x   Binary file utilities - Amiga src+diffs 
binutils                  1.8.x   Binary file utilities - orig FSF source.
bismarkplus                 ?.?   Schlachtschiff Bismarck raytrace        
bison                      1.22   GNU Parser generator - Amiga binary     
bison                      1.22   GNU Parser generator - Amiga src + diffs
bison                      1.22   GNU Parser generator - Orig FSF source. 
bsplit                      1.0   Split files into pieces by byte count   
cP                          4.2   Data plotting program for 2D data       
cam                         ?.?   640x512x24 JPEG raytrace using Imagine 2
chksum                      1.0   SVR4 "sum" compatible checksum program  
cpio                        2.3   Copy to/from archives - Amiga binary    
cpio                        2.3   Copy to/from archives - Amiga src+diffs 
cpio                        2.3   Copy to/from archives - orig FSF source.
db                          1.0   Small and fast database program         
dc                          0.2   GNU RPN desk calc - Amiga binary & docs.
dc                          0.2   GNU RPN desk calc - Amiga source + diffs
dc                          0.2   GNU RPN desk calculator - Orig FSF src. 
diffutils                   2.6   Diff & cmp utils, Amiga binary + docs   
diffutils                   2.6   Diff & cmp utils, Amiga source + diffs  
diffutils                   2.6   Diff & cmp utils, original FSF src dist.
doschk                      1.1   Check DOS/SYSV filenames, Amiga bin+docs
doschk                      1.1   Check DOS/SYSV filenames, Amiga src+diff
doschk                      1.1   Check DOS/SYSV filenames, orig FSF src. 
emacs                     18.59   GNU Emacs editor, Amiga binaries & docs.
emacs                     18.59   GNU Emacs editor, Amiga source & diffs. 
emacs                     18.59   GNU Emacs editor, original FSF source.  
f1                          ?.?   948x428x24 JPEG raytrace, formula 1 car 
f2c                    93.04.28   F77 to C translator, Amiga bin+libs+docs
f2c                    93.04.28   F77 to C translator, Amiga source+diffs 
f2c                    93.04.28   F77 to C translator, orig FSF source.   
fd2pragma                   2.0   Pragmas, LVOs for Aztec, Dice, SAS, Maxo
fd2pragma                   2.0   Pragmas/LVOs for Aztec, Dice, SAS, Maxon
fifolib                    37.4   A general fifo library implementation   
fileutils                   3.9   File management utils, Amiga bins+docs. 
fileutils                   3.9   File management utils, Amiga src+diffs  
fileutils                   3.9   File management utils, FSF source dist  
find                        3.8   Find, xargs, and locate; Amiga bin+docs 
find                        3.8   Find, xargs, and locate; Amiga src+diffs
find                        ?.?   Find, xargs, and locate; orig FSF source
flex                      2.4.6   Makes lexical analyzers, Amiga bin+docs 
flex                      2.4.6   Makes lexical analyzers, Amiga src+diffs
flex                      2.4.6   Makes lexical analyzers, orig FSF source
gas                      1.38.1   GNU assembler, Amiga binary + docs.     
gas                      1.38.1   GNU assembler, Amiga source + diffs.    
gas                      1.38.1   GNU assembler, orig FSF source dist.    
gawk                     2.15.4   Pattern scan & process, Amiga bin+docs. 
gawk                     2.15.4   Pattern scan & process, Amiga src+diffs.
gawk                     2.15.4   Pattern scan & process, orig FSF source.
gcc                       2.3.3   C/C++/Obj-C compiler, Amiga bin + doc.  
gcc                       2.3.3   C/C++/Obj-C compiler, Amiga src + diffs 
gcc                       2.3.3   C/C++/Obj-C compiler, orig FSF src dist 
gcc                       2.5.8   C/C++/Obj-C compiler, Amiga bin + doc.  
gcc                       2.5.8   C/C++/Obj-C compiler, Amiga src + diffs 
gcc                       2.5.8   C/C++/Obj-C compiler, orig FSF src dist 
gdb                        4.12   GNU debugger, Amiga binary and docs.    
gdb                        4.12   GNU debugger, Amiga source and diffs.   
gdb                        4.12   GNU debugger, orig FSF source dist.     
gdbm                      1.7.1   Database manager library, Amiga bin+docs
gdbm                      1.7.1   Database manager library, Amiga src+diff
gdbm                      1.7.1   Database manager library, orig FSF src. 
gdbtest                    4.12   GNU debugger testsuite, orig FSF source.
ghostscript               2.6.1   Ghostscript interpreter, orig FSF fonts.
ghostscript               2.6.1   Ghostscript interpreter, orig FSF source
ghostscript             2.6.1.4   Ghostscript interpreter patches 1-4     
ghostscript             2.6.1.4   Ghostscript interpreter, Amiga bin+docs.
ghostscript             2.6.1.4   Ghostscript interpreter, Amiga src+diffs
gmp                       1.3.2   Arbitrary precision math, Amiga bin+docs
gmp                       1.3.2   Arbitrary precision math, Amiga src+diff
gmp                       1.3.2   Arbitrary precision math, orig FSF src. 
grep                        2.0   GNU grep package, Amiga binaries + docs.
grep                        2.0   GNU grep package, Amiga source + diffs. 
grep                        2.0   GNU grep package, original FSF source.  
groff                      1.09   Document formatting sys, Amiga bin+docs.
groff                      1.09   Document formatting sys, Amiga src+diffs
groff                      1.09   Document formatting sys, orig FSF source
gzip                      1.2.4   Compress/decompress, Amiga bin + doc    
gzip                      1.2.4   Compress/decompress, Amiga src + diff   
gzip                      1.2.4   Compress/decompress, orig FSF src dist  
hornlife                    ?.?   Imagine rendered still-life             
indent                    1.9.1   C code beautifier, Amiga binary + docs. 
indent                    1.9.1   C code beautifier, Amiga source + diffs.
indent                    1.9.1   C code beautifier, orig FSF source dist.
ispell                      4.0   Spelling checker, Amiga binary + docs.  
ispell                      4.0   Spelling checker, Amiga source + diffs. 
ispell                      4.0   Spelling checker, orig FSF source dist. 
ixemul                    39.47   Unix emulation environment, Amiga lib.  
ixemul                    39.47   Unix emulation environment, devel files.
landed                      ?.?   1024x768 JPEG image of probe on venus   
libg++                    2.5.3   C++ class library, Amiga library + docs.
libg++                    2.5.3   C++ class library, Amiga source + diffs.
libg++                    2.5.3   C++ class library, orig FSF source dist.
libm                        x.x   Math library, Amiga library + docs.     
libm                        x.x   Math library, Amiga source + diffs.     
m4                        4.1.1   Macro processor, Amiga binary + docs.   
m4                        4.1.1   Macro processor, Amiga source + diffs.  
m4                        4.1.1   Macro processor, orig FSF source dist.  
make                       3.70   POSIX compatible make, Amiga binary+docs
make                       3.70   POSIX compatible make, Amiga src+diffs. 
make                       3.70   POSIX compatible make, orig FSF docs.   
make                       3.70   POSIX compatible make, orig FSF source. 
mg                           3b   Small GNU EMACS style editor with AREXX 
patch                       2.1   Apply diff file, Amiga binary + docs.   
patch                       2.1   Apply diff file, Amiga source + diffs.  
patch                       2.1   Apply diff file, orig FSF source dist.  
pdksh                       4.5   A UNIX ksh compatible shell for AmigaDOS
pdksh                       4.5   PD ksh compatible shell, Amiga bin+docs.
pdksh                       4.5   PD ksh compatible shell, Amiga source.  
perl                      4.036   Extraction & Report Lang, Amiga src+diff
perl                      4.036   Extraction & Report Lang, orig FSF src. 
rcs                     5.6.0.1   Revision Control System, Amiga bin+docs.
rcs                     5.6.0.1   Revision Control System, Amiga src+diffs
sed                        2.03   GNU stream editor, Amiga binary + docs. 
sed                        2.03   GNU stream editor, Amiga source + diffs.
sed                        2.03   GNU stream editor, orig FSF source dist.
shellutils                1.9.4   Shell utilities, Amiga binary + docs.   
shellutils                1.9.4   Shell utilities, Amiga source + diffs.  
shellutils                1.9.4   Shell utilities, orig FSF source dist.  
submarine                   ?.?   Photorealistic undersea rendering       
tar                      1.11.2   GNU Tape Archiver, Amiga binary + docs. 
tar                      1.11.2   GNU Tape Archiver, Amiga source + diffs.
tar                      1.11.2   GNU Tape Archiver, orig FSF source dist.
termcap                     1.2   Termcap library, Amiga library + docs.  
termcap                     1.2   Termcap library, Amiga source + diffs.  
termcap                     1.2   Termcap library, orig FSF source dist.  
texinfo                     3.1   Documentation system, Amiga binary+docs.
texinfo                     3.1   Documentation system, Amiga src+diffs.  
texinfo                     3.1   Documentation system, orig FSF source.  
textutils                   1.9   Text processing utils, Amiga bin+docs.  
textutils                   1.9   Text processing utils, Amiga src + diffs
textutils                   1.9   Text processing utils, orig FSF source. 
true                        1.0   Simple versions of "true" and "false"   
tsiwf                       ?.?   JPEG Imagine 2.0 raytraced image.       
uuencode                    1.0   Encode/decode utils, Amiga binaries+docs
uuencode                    1.0   Encode/decode utils, Amiga source+diffs.
uuencode                    1.0   Encode/decode utils, orig FSF source.   
zoo                         2.1   Portable archiver with good compression 
--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA2@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.



