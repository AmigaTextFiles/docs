Short:    Cheap SmartMedia interface + sourcecode
Uploader: jel@netti.fi (Janne Lumikanta)
Author:   jel@netti.fi (Janne Lumikanta)
Type:     hard/hack
Version:  0.3

------------------------------------------------------------------------------
0. DISCLAIMER
===============
Use this hardware and software at your own risk.

Take a backup of formatted card before writing as I've read that
some digicams doesn't regonize SmartMedia if first blocks of card
are not ok. 
..And I actually made my own 16MB SmartMedia incombatible with
my Fujifilm FinePix 4700Zoom with this version, so I recommend
to use this software and hardware only for reading.




1. QUICK INFO
===============
3.3V SmartMediaTM (SSFDC) parallelport interface for Amiga

Hardware:

·compatible with 3.3V SmartMedia
·very cheap, costs less than 10$ to build
·quite simple, only 3 HCTTL-chips
·it works without external powersupply
·schematics included


Software:

·c-sources included
·no GUI yet
·rawread and rawwrite supported
·no support for FAT yet, it seemed quite insane
·extract all JPEG files automatically, fragmented images won't work
·seems to work with kickstart 1.3, it crashed on exit
·1Mbit/s download rate with 68060, 100kbit/s with 68000
·combatible with 16MB, 32MB, 64MB and 128MB SmartMedia





2. AUTHOR
===========
Hi, I'm Janne Lumikanta, you may remember me from such a projects
like PSX-MemCardTool and some never released AMOS projects, maybe
I'll create a website. I live in Turku, Finland. You can contact
me by E-mail, jel@netti.fi





3. DISTRIBUTION & COPYRIGHT
=============================
This project is freeware, it may be distributed everywhere.
If you have interest to massproduce the hardware, do it, sell it,
but it would be nice if you mention the original author somewhere.





4. REQUIREMENTS
=================
Amiga with ParallelPort, maybe any AmigaOS, tested under AmigaOS 3.5
and AmigaOS 1.3 (it crashed on exit with AmigaOS 1.3).
16MB, 32MB, 64MB or 128MB SmartMediaTM card.





5. HARDWARE
=============
I WILL NOT BUILD THIS HARDWARE TO ANYONE, THIS IS A DIY PROJECT.
Here comes the list of required components,

------------------------------------------------------------------------------

Type        How many    Description

74HC00         1        Quad 2-input NAND gates
74HC245        1        8-bit 3-state noninverting bus transceiver
74HC573        1        8-bit 3-state transparent latch.
LM317 (LZ)     1        Adjustable regulator, LZ version is nice

LED            1        Optional busy led

240   ohm      1        Resistor
680   ohm      1        ""
1k    ohm      3        ""
2.2k  ohm      2        ""

100pF          1        Ceramic
100nF          4        Tantalum
1µF            1        ""

25pin D-male   1        Connection to parallelport
22pin SM-slot  1        SmartMedia connector

PCB                     

------------------------------------------------------------------------------

I made my SmartMedia connector from 4 mobilephone SIM-connector,
you can use pins taken from a cardedge connector. I drew a model of
SmartMedia to a piece of transparent plastic, it helped placing the
pins and the card guidance pieces to the correct place.





5. SOURCE CODE
================
Software is my first useful C-project for the Amiga, I've been
playing with AMOS too much before. No GUI in this beta release.
Developing configuration was:

Amiga 3000  with  128MB FAST + 2MB CHIP
                  CyberStormPPC 060-50MHz/604e-200MHz
                  AmigaOS 3.5
                  SAS-C

Toshiba's SmartMedia timing diagrams will help with understanding 
the sources and why the hardware is what it is. 
See the WEBLINKS section. I'll propably continue developing of 
the software and hopefully include some useful features to it.





6. USAGE
==========
Current version is a CLI-program.

Typing 

´smif´

will test the hardware and prints out maker code (0x98=Toshiba),
device code (0x73=16MB, 0x75=32MB, 0x76=64MB, 0x79=128MB),
and if supported card was detected, it'll print usage info.

  smif getjpg -o <basename>
  smif read -o <outfile> -s <startaddress> -l <length>
  smif write -i <infile> -s <startaddress>


Examples

´smif getjpg -o work:digi/pic´
saves all JPEG files as work:digi/picxxxx.JPG

´smif read -o PIECE -s 0x24000 -l 0x100000´
grabs 1MB starting from address 0x24000 (dec 147456) to file PIECE

´smif write -i Darkwell.jpg -s 262144´
writes Darkwell.jpg to SmartMedia starting from address 0x40000\n");




Don't overwrite first blocks of card if you haven't backed up working
image of whole card as some digicams may have problems if first block
is not ok. Read the file WARNING.

Fragmented JPEG-files won't work with ´getjpg´, so I recommend to
format card with digicam before taking pictures.




7. HISTORY
============
V0.1   15-04-2001
       first public release
       getjpg, read and write options
       only support for startaddress modulo of 512 this time

V0.2   27-04-2001
       write mode is now working (I thought that I tried it..)

V0.3   22-08-2001
       write was only possible to blocks that was empty,
       now you should be able to write anywhere 




8. TO DO
==========
-GUI
-Extract all files with correct filenames, I became sick when I tried
 to understand how FAT12 startblock is calculated, it would be easy
 if someone finds out how to mount the whole cardimage as FAT-filedisk,
 please send me the mountfile, I tried several configurations but none
 of them worked, maybe because the bootsector wasn't at the beginning
 of the image.





9. WEBLINKS
=============
checked at 27-04-2001

http://www.toshiba.co.jp/mediacd/eng/smartmedia/index.htm
http://doc.semicon.toshiba.co.jp/seek/us/td/01mos/010028.htm
http://www.ssfdc.or.jp
http://www.butaman.ne.jp/~tsuruzoh/Computer/Digicams/exif-e.html
http://www.pima.net/standards/iso/tc42/wg18/ISO12234_all/N4718_DIS12334-3.PDF




