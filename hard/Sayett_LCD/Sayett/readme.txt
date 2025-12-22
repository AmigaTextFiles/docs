--------------------------------------------------------
Sayett DATASHOW HR/M LCD panel for an overhead projector
--------------------------------------------------------
By:       Chris Sterne
Date:     May 3, 1999
Email:    chris_sterne@panam.wimsey.com
Location: Vancouver, British Columbia, Canada
--------------------------------------------------------

------------
Introduction
------------

This hardware project is an Amiga video port interface to a Sayett
DATASHOW HR/M LCD panel video port.  The Sayett panel lies on an
overhead projector, projecting a non-interlaced 640x400 monochrome
screen image.

-------------------
Panel Modifications
-------------------

If the Sayett panel has a label on the back, reading "This system
has been designed for use with Apple Macintosh Plus and Macintosh
SE computers only", two modifications will need to be done to expand
its display capabilities to 640x400 pixels.

- The internal LCD display will be partly covered with a black mask.
  Remove the screws holding this to the LCD frame, then return the
  screws to the frame.

- An onboard EPROM (chip U7) forces the display to show a screen area
  of 512x348 pixels.  Remove this EPROM, and tie all eight data lines
  that were used by the EPROM to ground through a 4K7 resistor (one
  resistor will serve all eight lines).  There is probably a way to
  tell the LCD Video Interface Controller (Hitachi HD66840FS) to ignore
  the EPROM, but that way is not presently known.

-----------------
Sayett Video Port
-----------------

The Sayett panel has a DB9 female video port, requiring a video
clock and data.  All signals are TTL levels.  The signals of this
port are described below:

(Pin 1, 2) CLOCK+, CLOCK-
  This differential pair is the video clock inputs.  A 330 ohm
  termination resistor joins these inputs.  The clock frequency
  must be greater than 6 MHz, otherwise the LCD panel drivers
  shut down (panel remains dark).  At present, it is not known
  which clock edge clocks in data.
  
(Pin 3, 4) DATA+, DATA-
  This differential pair is the digital video data inputs.  A 330
  ohm termination resistor joins these inputs.
  
(Pin 5) HSYNC#
  This is the active-low horizonal synchronization pulse input.
  It is terminated by a 330 ohm resistor to ground.  A pulse width
  of one clock appears to be all that is required.

(Pin 6) VSYNC#
  This is the active-low vertical synchronization pulse input.
  It is an unterminated TTL-type input.  A pulse width of one clock
  appears to be all that is required.

(Pin 7) +5V Power
  This unfused pin is connected to the panel's +5V power plane.
  
(Pin 8) Ground
  This pin is connected to the panel's ground plane. 

(Pin 9) Unused

-----------------
Sayett Power Port
-----------------

The Sayett panel has a 5mm round power connector on its back.  The
center pin is +5 VDC, while the outer ring is ground.  The required
current (measured) is 200 mA.

---------------------
Amiga Video Interface
---------------------

(See "diagram.iff" file)

The Amiga interface drives a 28.322 MHz video clock into the Amiga,
in order to control the relationship between this video clock and the
resulting video data from the Amiga.  A second-hand TTL oscillator
from an old IBM PC/AT video card can be used.  The frequency of this
oscillator is not critical; 28.322 just happened to be close to the
internal 28 MHz fundamental clock frequency of an Amiga.

Digital video data is obtained from the Amiga's Digital Blue output,
but the Digital Red or Green could be used as well.

The video clock and data are driven onto a video cable with a 26LS31
differential line driver.  The remaining drivers are used in a single-
ended manner for the horizonal and vertical synchronization pulses.

If the resulting LCD display seems to be missing pixels, or is unsteady,
an accumulation of delays may have resulted in either a video data setup
or hold time violation at the Sayett panel.  Reversing the CLOCK+ and
CLOCK- signals will shift the clock by 90 degrees, which should fix the
problem.  One flaw with the interface is that the line driver adds a
delay (20ns maximum) between the Amiga video clock and Sayett video
clock, which complicates predicting this clock to data relationship.
This is compounded by the fact that, at present, the timing details of
the Sayett video input are unknown.

The entire interface will fit within the shell of a DB23 connector.

-----------------
Video Adjustments
-----------------

The Sayett panel has an area reserved for screen positioning buttons,
but none are present.  As well, the panel's ciruit board does not have
any reserved connectors for positioning controls.  Any adjustments will
have to be done on the Amiga side.

The two files, "dblNTSC.info" and "overscan.prefs", have been configured
to produce a properly positioned screen for a Sayett panel.  Copy
"dblNTSC.info" to DEVS:Monitors and "overscan.prefs" to ENVARC:SYS.  A
backup of existing copies of these files should first be made before they
are overwritten (It should be noted that the settings may not work well
with a real monitor).  The resulting non-interlaced DBLNTSC display modes
will produce a full-size display on the Sayett panel:

- DBLNTSC:High Res
- DBLNTSC:High Res No Flicker
- DBLNTSC:Low Res
- DBLNTSC:Low Res No Flicker

An alternative to using the provided monitor and overscan files would be 
temporary solution using the "Moned3A" screen adjustment program
available from Aminet.  The "Moned3A" settings are:

Horizontal Blanking Start HBSTRT   000
Horizontal Sync Start     HSSTRT   018
Horizontal Sync Stop      HSSTOP   020
Horizontal Blanking Stop  HBSTOP   020
Total Horizontal Clocks   TOTCLKS  076
Vertical Blanking Start   VBSTRT   0000
Vertical Sync Start       VSSTRT   0AAD
Vertical Sync Stop        VSSTOP   0C4E
Vertical Blanking Stop    VBSTOP   0F51
Total Vertical Lines      TOTROWS  01AA

------------------------
Video Limit Observations
------------------------

If the Sayett panel receives more than 400 scan lines, the extra ones
will be ignored.  A screen with less than 400 lines will be accepted,
but there may be garbage in the remaining panel area.  If a scan line
is shorter than 640 video clocks, the next scan line will be ignored.

-----------
Test System
-----------

This interface worked successfully on an accelerated A1200 system.
