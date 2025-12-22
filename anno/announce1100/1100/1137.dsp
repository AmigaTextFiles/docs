From zerkle Wed Apr 26 03:35:00 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA27272; Wed, 26 Apr 95 03:34:58 PDT
Received: from aino.it.lut.fi by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA27264; Wed, 26 Apr 95 03:34:49 PDT
Received: from localhost (petsalo@localhost) by aino.it.lut.fi
 (8.6.5/8.6.5/1.12.kim) id NAA02454; Wed, 26 Apr 1995 13:34:40 +0300
 (for announce@cs.ucdavis.edu)
From: Jyrki Petsalo <Jyrki.Petsalo@lut.fi>
Message-Id: <199504261034.NAA02454@aino.it.lut.fi>
To: announce@cs.ucdavis.edu
Date: Wed, 26 Apr 95 13:34:39 EET DST
X-Mailer: ELM [version 2.3 PL11]
Subject: SUBMIT Delfina DSP audio board
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

submit
Followup-To: comp.sys.amiga.audio
Reply-To: Jyrki.Petsalo@lut.fi

                 PRELIMINARY INTRODUCTION TO THE DELFINA DSP


1. WHAT IS DELFINA DSP?

Delfina DSP is a multifeatured audio board containing a fully programmable
powerful 20 MIPS Digital Signal Processor. The board is capable of 16bit 
stereo digitizing and multichannel playback at 50kHz. Price will be under 
$700, with an introductionary price for the Internetters at $400.

Features:

	- 40 MHz Motorola DSP56002 processor
		* 20 MIPS
		* 24 bit data bus
		* 56 bit accumulators
		* Most instructions executed in one cycle

	- 96k/192k/384k SRAM
		* Dual ported (addressable from Amiga)
		* Zero-waitstate (25ns)

	- Stereo AD/DA (analog-digital-analog) converter (CS4215)
		* Sample frequencies upto 50 kHz 
		* 16 or 8 bit linear, u-law or A-law audio data coding
		* Programmable gain and attenuation
		* Microphone and line level inputs
		* Headphone and line level outputs
		* On-chip anti-aliasing/smoothing filters

	- High-speed RS232 interface (max. 2.5Mbit/s)

	- Centronics interface

	- Zorro II interface

	- Fully programmable using included libraries


Software:

DELFINA software version 0.9 beta includes the following:
 
	- delfaudio.library
		* multiple 16-bit or 8-bit channels
		* sound digitizing 
		* samples in PC or Amiga format
		* sample rates upto 48 kHz
		* channel panning and other effects

	- delfina.library
		* for user's own DSP software
		* several DSP programs can be configured as interrupts
		* full mastership of the card possible

	- delfser.device
		* serial.device compatible
		* max. 115200 bps
		* minimal CPU usage on Amiga

	- delfpar.device
		* parallel.device compatible
		* minimal CPU usage on Amiga 

More sofware will be released later. 


2. HOW AND WHY TO CONTACT US?

The board is at prototype stage, so changes can still be made according to
good propositions and requirements. The libraries and applications for
the card will be continuously developed even after the product has been
shipped, so we will be always open for fresh ideas. We'd be glad to 
join the discussion about wishes for features on the Internet News.

For information, reply or mail to:

Teemu.Suikki@lut.fi     (design, software)
Jyrki.Petsalo@lut.fi    (marketing)

-----------------------------------------------------------------------
               Delfina DSP. Discover the Sound of Power.


