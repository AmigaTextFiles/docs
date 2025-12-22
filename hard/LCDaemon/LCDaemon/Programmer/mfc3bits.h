#define MFC3_PADWIDTH	255
#define	MFC3_PIA_OFFSET	0x4000

struct mfc3 {
	UBYTE	mfc_pa;		/*	port A data & data direction register	*/
	UBYTE	mfc_pad1[MFC3_PADWIDTH];
	UBYTE	mfc_pacr;	/*	port A control register					*/
	UBYTE	mfc_pad2[MFC3_PADWIDTH];
	UBYTE	mfc_pb;		/*	port B data & data direction register	*/
	UBYTE	mfc_pad3[MFC3_PADWIDTH];
	UBYTE	mfc_pbcr;	/*	port B control register					*/
};
