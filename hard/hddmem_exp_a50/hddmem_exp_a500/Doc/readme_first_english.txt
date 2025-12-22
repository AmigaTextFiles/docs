
                       Introduction.

This archive contains the information to building memory expansion card,
connecting IDE HDD and new kickstart to the M68000-based Amiga500. A600
users also could build this expansion card in order to connect new
kickstart and fastRAM, but in that case the PCMCIA won't be available, or
it will, but you'll be limited to only 4Mb RAM. A table of A500 expansion
slot pins and pins of A600 chips is given at the end of this file.

  This card starts to work right after switching on your Amiga and doesn't
require any drivers etc. to be loaded into memory. HDD can be formatted
using plain HDToolBox and plain scsi.device. The memory made on a 0 wait
states basis.

                   Scheme capabilities.

  This scheme was built with more than three years experience of making
devices for A500/A1200. The prototype was given in the previous project,
hard/hack/hddmem.lha. This scheme was simplified a lot, some functions were
removed and some minor changes in the kickstart were made. The scheme is
also optimized hardly and now is based on SIMM4/8Mb. Autoconfig wasn't
added as it isn't needed ;-).

 There are two ways to build the card:

1. 19 chips without plddd21 chip. This card has minimum of working 
   capabilities and requires installation of kickstart 39.106 with some
   changes. This is describes in doc/rom_kick.txt file. The card is tested
   and it works OK.

2. 7 chips (pld dd21, dd16, dd17, dd18, dd20, dd14, dd15). In this case the
   card completely emulate A600/A1200 IDE ports, but you need a "flexible
   logic" chip FX740LC68 or FX840LC68 for this (check doc/pld.txt for more
   information). Software control of scheme configuration is also based on
   a pld chip. Unfortunately, this variant needs some experience of working
   with pld, and it didn't pass final tests due to problem concerned with
   pld chips buying.

                  Building and debugging tips

1. Read all the docs carefully.
2. Widen the power supply tracks, if your technological equipment allows it.
3. Widen the holes for all the slots, but the SIMM slot.
4. Don't use EDO SIMM (but, probably, EDO will work too).
5. Start debugging in this sequence: rom -> hdd -> fast ram.
6. Use the programs from Prog/ directory for debugging.
7. If HDD doesn't work, try to connect data bus to +5v with 1K pull-up
   resistors.


                     Archive contents.

  This archive contains these directories:

Doc         Documetation
Gfx         Useful schemes and drawings
Pcad4_5     Scheme of the board in PCAD format for IBM PC
            If you can't get a PCAD, check #?.png files
Photo       Photos of the card
Pld         Files for pld chip version of a card
Roms        Files for extracting ROM
Prog        Some useful programs for debugging
fonts       Russian font, codepage 866 (ms-dos) for Amiga

  This archive contains these directories and files:

Directory "fonts"
866.font                     264  russian fonts

Directory "fonts/866"
8                           3112  russian fonts

Directory "Doc":
block_english.txt          modular principal scheme
electric_english.txt       electrical description of a scheme (without pld)
bugs_english.txt           Known bugs
readme_first_english.txt   no comment ;)
pld_english.txt            about pld chip version of a card
rom_kick_english.txt       how to patch a kickstart
chip_list.txt

Directory "Gfx":
Diagram.png                 timing diagrams of the scheme
sborka.png                  constructing drawing
plata.png                   board dimensions
Func1.png                   structural scheme of the whole board
fx-740.png                  structural scheme of the PLD chip
tex.png                     technical and economical desriptors

Directory "Gfx/Real_work_diagram":
7_mhz_cdac.dsa              diagrams of 7mhz and cdac signals
as_ramsel_ras_se_cas.dsa    diagrams of dynamic memory signals
How_view                    how to view the diagrams

Directory "Pcad4_5"
Kontr.SCH                   principal electrical scheme (pcad4_5)
Kontr_1.HP                  principal electrical scheme (pcad4_5)
(CorelDraw file)
Kontr_2.HP                  principal electrical scheme (pcad4_5)
(CorelDraw file)
Kontr_1.HPP                 file for laser printer
Kontr_2.HPP                 file for laser printer
Kontr_1.png                 principal electrical scheme (part 1/2)
Kontr_2.png                 principal electrical scheme (part 2/2)
Kontr8.PCB                  board scheme in pcad4_5
Kontr8.png                  board scheme in pcad4_5
Kontr8_component.png        board scheme in pcad4_5
Kontr8_component.HP         board scheme in pcad4_5 (CorelDraw file)
Kontr8_solder.png           board scheme in pcad4_5
Kontr8_solder.HP            board scheme in pcad4_5 (CorelDraw file)

Directory "Pcad4_5/REAL_OLD"
KONTR.SCH                   old principal electrical scheme (with
bugs)
KONTR8.PCB                  old board scheme (with bugs)
Kontr_1.png
Kontr_2.png

Directory "Photo"
brds.png
component_side_1.png
component_side_2.png
solder_side_1.png
solder_side_2.png
Vladimir_Sobolev.png

Directory "Pld"
HM010.BIT                   ROM image for PLD
HM010.ERR
HM010.HST                   all PLD simulation diagrams
HM010.JED                   ROM image for PLD
HM010.PDS                   source file for creating ROM image
HM010.PIN
HM010.RPT
HM010.TRF                   given diagrams for PLD simulation
state_machine.png
VC.EXT

Directory "Prog"
add4m                       adds 4Mb from $200000
add8m                       adds 8Mb from $200000
External_rom_copy           copies another kickstart without leaving
the current one
External_rom_copy.s
HDReset                     Software HDD reset using cs1
HDReset.s
port                        for debugging ports and memory usage with
oscilloscope
port.s
s0_read                     reads HDD 0 sector into memory $0f0000-$0f01ff
s0_read.s

Directory "Prog/Kick_check_sum"
RomF8Check                  checks kickstart check sum
RomF8Check.s
RomF8CheckSumWrite          writes kickstart check sum into rom
RomF8CheckSumWrite.s

Directory "Roms"
ROM_A1200_V39.106_M0.dif      file for creating rom image (w/o pld)
ROM_A1200_V39.106_M0_c0.dif   file for creating rom image (w/o pld)
rom_split                     splits rom in two 8-bit images
rom_split.c

Directory "Roms/File_diff"
diff_cut                     creates diff-file
diff_cut.c
diff_paste                   recovers source file
diff_paste.c
diff_view                    views diff-file
diff_view.c
readme.txt
SCOPTIONS


                                 Authors.

  The part with no pld is worked out by Dmitry Gzhibovsky using the data
from hddmem project and his own ideas and projects.

  The part with created by Vladimir Sobolev using the data
from hddmem project and his own ideas and projects.

  PCAD design made by Natasha Gordievskih and Vladimir Sobolev.

  Scheme and board correction, documetation, rom image patch, service
programs and debugging card w/o pld by Vladimir Sobolev.

  English translation by Andrew "Notorious" Boyarintsev and Labutcky D.

  This project is freeware, so you are free to use it upon your wishes.

  Please, send all comments and notes to Vladimir Sobolev or Dmitry Gzhibovsky.

  Authors take no responsibility for this scheme. You make it on your own
risk.


                                 Address.

Author:   Vladimir Sobolev
Place:    Russia, Ekaterinburg
E-mail:   sobolev@dc.ru
          ys-magic@dialup.mplik.ru
          amiga_man@usa.net
          vsobolev@hotmail.com
FIDO:     2:5080/52.69
AmigaNet: 39:245/200.3
IRC:      irc.msu.ru  /join #amigarus  or  /query vlso

Author:   Dmitry Gzhibovsky
Place:    Russia, Ekaterinburg
E-mail:   ldk@channel4.ru
FIDO:     2:5080/160.0
AmigaNet: 39:245/200.0

Translator: Andrew Boyarintsev
Place:      Russia, Moscow
HomePage:   http://come.to/lkr
E-mail:     ntrs@redline.ru
IRC:        irc.stealth.net  /join #amigarus or /query nOT^LkR

Translator: Labutcky D.
Place:      Ukraina
E-mail:     AVL@ccssu.crimea.ua

                                A600 Users

  Unfortunately, A600 doesn't have a system slot, but you can connect all
contacts to the board putting panels on chips.  You have to make the same
versions of a board, but in version w/o pld (dd21) you shouldn't put these
elements:
dd10, dd11, dd12, r2, c1, as they are needed for IDE controller only.
Among this, pins 1 and 4 of dd13 should be disconnected from connected
circuits and connected to +5v, or pins 3 and 6 of dd13 should be
disconnected from board (unbend them).  The "ground" of the Amiga and the
board should be connected with optimally short wires (not less than 10),
and +5v may be connected using half of this amount of wires.

  Furthermore, you won't have pcmcia, because it is removed in this rom
image. Of course, you can make a pld version of the card and use the
standard rom, but then carddisk.device will recognize only 4Mb of fast ram.
You'll have to add other 4Mb with prog/add4m program. But you can make
your own patch, as I did... ;)

  Correspondence A500 system slot and €600 chips:

a500 pin number | a500 pin name || a600 chip name | a600 pin number
--------------------------------------------------------------------
       1        |     gnd       ||  mc68000       |        16
       2        |     gnd       ||  mc68000       |        17
       3        |     gnd       ||  mc68000       |        56
       4        |     gnd       ||  mc68000       |        57
       5        |     +5v       ||  mc68000       |        14
       6        |     +5v       ||  mc68000       |        52
       7        |     nc        ||    -           |        -
       8        |     -5v       ||    -           |        -
       9        |     nc        ||    -           |        -
      10        |     +12v      ||  fdd power     |
      11        |     nc        ||    -           |        -
      12        |   gnd, cfg in ||    -           |        -
      13        |     gnd       ||  mc68000       |        16
      14        |     /c3       ||    -           |        -
      15        |     cdac      ||    *           |        *
      16        |     /c1       ||    -           |        -
      17        |     /OVR      ||    **          |        **
      18        |     RDY       ||    -           |        -
      19        |     /INT2     ||    -           |        -
      20        |     nc        ||    -           |        -
      21        |     A5        ||  mc68000       |        36
      22        |     /INT6     ||    -           |        -
      23        |     A6        ||  mc68000       |        37
      24        |     A4        ||  mc68000       |        35
      25        |     gnd       ||  mc68000       |        17
      26        |     A3        ||  mc68000       |        34
      27        |     A2        ||  mc68000       |        33
      28        |     A7        ||  mc68000       |        38
      29        |     A1        ||  mc68000       |        32
      30        |     A8        ||  mc68000       |        39
      31        |     FC0       ||     -          |        -
      32        |     A9        ||  mc68000       |        40
      33        |     FC1       ||     -          |        -
      34        |     A10       ||  mc68000       |        41
      35        |     FC2       ||     -          |        -
      36        |     A11       ||  mc68000       |        42
      37        |     gnd       ||  mc68000       |        56
      38        |     A12       ||  mc68000       |        43
      39        |     A13       ||  mc68000       |        44
      40        |     /IPL0     ||     -          |        -
      41        |     A14       ||  mc68000       |        45
      42        |     /IPL1     ||     -          |        -
      43        |     A15       ||  mc68000       |        46
      44        |     /IPL2     ||     -          |        -
      45        |     A16       ||  mc68000       |        47
      46        |     BEER*     ||     -          |        -
      47        |     A17       ||  mc68000       |        48
      48        |     /VPA      ||     -          |        -
      49        |     gnd       ||  mc68000       |        57
      50        |     E Clock   ||  mc68000       |        22
      51        |     /VMA      ||     -          |        -
      52        |     A18       ||  mc68000       |        49
      53        |     /reset    ||  mc68000       |        20
      54        |     Al9       ||  mc68000       |        50
      55        |     /HLT      ||     -          |        -
      56        |     A20       ||  mc68000       |        51
      57        |     A22       ||  mc68000       |        54
      58        |     A21       ||  mc68000       |        53
      59        |     A23       ||  mc68000       |        55
      60        |     /BR       ||     -          |        -
      61        |     gnd       ||  mc68000       |        16
      62        |     /BGACK    ||     -          |        -
      63        |     D15       ||  mc68000       |        58
      64        |     /BG       ||     -          |        -
      65        |     D14       ||  mc68000       |        59
      66        |     /DTACK    ||  mc68000       |        10
      67        |     D13       ||  mc68000       |        60
      68        |     rd_wr     ||  mc68000       |        9
      69        |     D12       ||  mc68000       |        61
      70        |     /LDS      ||  mc68000       |        8
      71        |     D11       ||  mc68000       |        62
      72        |     /UDS      ||  mc68000       |        7
      73        |     gnd       ||  mc68000       |        17
      74        |     /AS       ||  mc68000       |        6
      75        |     D0        ||  mc68000       |        5
      76        |     D10       ||  mc68000       |        63
      77        |     D1        ||  mc68000       |        4
      78        |     D9        ||  mc68000       |        64
      79        |     D2        ||  mc68000       |        3
      80        |     D8        ||  mc68000       |        65
      81        |     D3        ||  mc68000       |        2
      82        |     D7        ||  mc68000       |        66
      83        |     D4        ||  mc68000       |        1
      84        |     D6        ||  mc68000       |        67
      85        |     gnd       ||  mc68000       |        56
      86        |     D5        ||  mc68000       |        68
--------------------------------------------------------------------

Notes:
"-" - means "no connection".
"*" - unfortunately, we don't have A600 scheme, but we know, that this
      signal is given by GAYLE chip...
      If you can't get A600 scheme, you may use this way to get cdac:

                                     +5v  4-------
                                     ------|/s   |
      -------------        ------         3|     |5     cdac
   +5v|4         3|28Mhz---|    |----------|c   q|----------
      | Oscilator |        ------          |     |
      | 28.375mhz |       invertor        2|     |
      |           |        74F04    -------|d    |6    /cdac
      |1         2|gnd             /       |   /q|----------
      -------------               /  +5v  1|     |
                                 /   ------|/r   |
                 pin 15 mc68000 /          -------
                 ---------------     KP1554TM2 (74AC74)
                  (cpuclk)          pin 7 - gnd; pin 14 - +5v

      Of course, you have to find in your A600 a 28mhz oscillator and
      invertor. It's not recommended to get it before the invertor, though
      you may try to, if you can't track out the signal from oscillator's
      pin 3.

      Meaning of the scheme: cdac signal should be moved 90 degrees from
                             cpuclk signal (7.09Mhz).

"**" - This signal is needed only in pld version. It should be one of
       Gayle's inputs. Probably, the scheme will work without it. :)


