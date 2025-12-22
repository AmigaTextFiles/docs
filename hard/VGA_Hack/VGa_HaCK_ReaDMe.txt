
  Amiga RGB -> PC VGA Hardware Hack

- "What is this?", you might think.

As the title says it's simply a hardware
hack for the serious Amiga user, letting nearly anyone connect a "standard"
PC-VGA monitor to the Amiga-computer.

- "How's it done then?", you continue!   =8^)

The trick is pretty simple if you know it! When the PC-monitor "needs" a
digitally HIGH sync-signal, the Amiga actually deliver a digitally LOW sync-signal.
And the other way. So to make those two things work together you ... invert
the sync-signals. The easiest way to do this is to use an Intergrated
Circuit (IC) called 74LS08N, which contains 4 AND-gates. (If you're into
digtal circuits you might know what to do by now!!) Gate 1 has it's input's
at pin 1 and 2 and it's output at pin 3. By hardwiring pin 1 and 2, the
output is OPPOSITE (also called inverted) to the input.
Phew ... A picture explains more than 2063 bytes ... have a look at the
enclosed picture "VGA_Hack.IFF"!

- "Is it possible I'm going to brake something?"

Yes!! Let an experienced person do the soldering according to the diagram.
Most electronics will not stand the electrical shock of +5V. Note that the
author of this doc and diagram has NO responsibilities for anything that
goes wrong ... though, the hack should be pretty easy to do!

- "Should I note anything else?"

Yeppers! The adaptor described in the IFF-file states that some crossing
might be needed. A friend (A4000-owner) to the author (A1200-owner) uses HIS
original VGA-converter, but was forced to build a adaptor-cable. The cable
is used to adapt the 15 pins (RGB-output) to 9 pins (VGA-socket). It can
also be used together with the described converter. Though, WHEN USED WITH
THE CONVERTER, CROSSING IN THE ADAPTOR ISN'T NEEDED. This is already done
in the converter.

- "Are you ever going to get finished with this doc?", you hopefully ask!

This hardware hack was done by TranXeye / Nova Lythern, after trying
several other hacks. But I found this solution being the best.  =B-»

And so do I hope that you people out there do ...
