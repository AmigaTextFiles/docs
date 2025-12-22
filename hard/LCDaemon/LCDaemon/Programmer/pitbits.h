struct pit {
	UBYTE	pit_pgcr;
	UBYTE	pit_pad1;
	UBYTE	pit_psrr;
	UBYTE	pit_pad2;
	UBYTE	pit_paddr;
	UBYTE	pit_pad3;
	UBYTE	pit_pbddr;
	UBYTE	pit_pad4;
	UBYTE	pit_pcddr;
	UBYTE	pit_pad5;
	UBYTE	pit_pivr;
	UBYTE	pit_pad6;
	UBYTE	pit_pacr;
	UBYTE	pit_pad7;
	UBYTE	pit_pbcr;
	UBYTE	pit_pad8;
	UBYTE	pit_padr;
	UBYTE	pit_pad9;
	UBYTE	pit_pbdr;
	UBYTE	pit_pad10;
	UBYTE	pit_paar;
	UBYTE	pit_pad11;
	UBYTE	pit_pbar;
	UBYTE	pit_pad12;
	UBYTE	pit_pcdr;
};

#define PITF_PartAPortC 0x85		/*	%10000101	*/
#define PITF_PartBPortC 0x52		/*	%01010010	*/

