---------------------------------------------------------------
Abaton SCAN 300/FB (Ricoh IS30-M2) flatbed scanner controller.
---------------------------------------------------------------
By Chris Sterne (chris_sterne@panam.wimsey.com), March 27, 1999
---------------------------------------------------------------

------------
Introduction
------------

This project was undertaken after obtaining an Abaton SCAN 300/FB
(based on a Ricoh IS30-M2 OEM mechanism) flatbed scanner that was
missing its SCSI interface "black box".  The scanner's interface
is similar to that used by Centronics-type printers, but some
differences required the reconditioning of signals.

-------------------------------------------
Scanner controller software: scan directory
-------------------------------------------

This directory contains a CLI-only scanner control program "Scan",
including its source code.  Type "Scan" without any arguments,
or "Scan ?", to see the program instructions.

--------------------------------------
Interface: interface.iff, waveform.iff
--------------------------------------

These files are a schematic of an Amiga parallel port to Abaton
parallel port interface and timing waveforms for access cycles.
This interface was necessary for the following reasons:

- The Amiga STROBE# signal is always an output, but the scanner will
  drive STROBE# during Read cycles, causing contention on the Amiga's
  STROBE#.  This is prevented by isolating the two signals.
  
- During Read cycles, the scanner presents data at the time it pulses
  STROBE#.  Even if the scanner STROBE# signal were to be connected to
  the Amiga's ACK# to generate an interrupt, the scanner data will most
  likely be gone by the time the Amiga can read it.  This is solved by
  latching the data and asserting BUSY.  When the Amiga sees BUSY
  asserted, it will know that data is available.  The assertion of BUSY
  will also tell the scanner to wait until the data is read.  After the
  data is read, the Amiga will generate a STROBE# pulse to reset the
  latch.

- The scanner needs a signal to tell it when to begin sending data.
  This is solved by changing the SEL input to an output, and renaming
  it to READ#.  The default state is negated, used when writing to the
  scanner.

Using standard DIP packages, the entire interface will fit within the
shell of a 36-pin connector on a parallel cable.

WARNINGS:

- According to the Amiga hardware manual, the SEL (being used as READ#)
  signal is shared with the Ring Indicator (RI) serial port signal in
  A2000 and A500 systems.  The effect of this sharing on the use of the
  READ# signal as an output is not known.
  
- The Abaton scanner must have been modified at the factory to supply
  5 volts on pin 35 and 36, allowing a SCSI interface box to be added.
  The parallel port interface draws power from the scanner.

--------------------------------
Scanner 36-pin connector signals
--------------------------------

(Pin 1) STROBE#, active LOW, Bidirectional, internal pullup.
  During Write cycles, STROBE# is an Input, indicating that valid data
  available.  During Read cycles, STROBE# is an Output, indicating that
  valid data is available.

(Pins 2 to 9) Data[0:7], Bidirectional, internal pullups.
  This bus is normally an Input, but becomes an Output if the scanner
  asserts ACK# when READ# is asserted.

(Pin 10) ACK#, active LOW, Output, internal pullup.
  This signal, which is always an Output, is pulsed to acknowledge data
  written to the scanner.  After receiving any command that will return
  data, ACK# will be returned for the last byte of the command sequence
  after all the data has been read, or after a timeout delay of 15 seconds.

(Pin 11) BUSY, active HIGH, Bidirectional, internal pullup.
  BUSY will be asserted after each byte is written to the scanner, then
  negated when ACK# is returned.  During Read cycles, BUSY is floated high,
  allowing it to be driven by an external source to control the data flow.

(Pins 12, 13, 32) ERROR, active HIGH, Output, internal pullup.
  When asserted, an error code is available to be read from the scanner.
  Internal jumpers (J7, J6, J5) select which pin is driven with the ERROR
  signal.  The default appears to be pin 15 (J5 installed, J6 and J7
  removed).

(Pins 14, 15) READ#, active LOW, Input, internal pullup.
  When negated, data may be written to the scanner.  When asserted, data
  may be read from the scanner.  Internal jumpers (J3 an J4) select the
  source pin of READ#.  The default appears to be pin 15 (J3 installed,
  J4 removed).

(Pins 16, 18, 33, 34) Unused.

(Pins 17, 19 to 30) Ground.

(Pin 31) RESET#, active LOW, Input, internal pullup.
  When asserted, the scanner will be reset to its power-up state.

(Pins 35, 36) +5v.

---------------------------------
Command code sequences: codes.txt
---------------------------------

This file contains the scanner's command codes.  These were obtained by
disassembling the scanner's operating system.  The purpose of some are
currently unknown, but the necessary ones (those that make the scanner
scan) are known.

------------------------------------------
FinalWriter ARexx script: FWImport_CD.rexx
------------------------------------------

This ARexx script can be run within the FinalWriter word processor to
automatically scan a business card and import the image.
