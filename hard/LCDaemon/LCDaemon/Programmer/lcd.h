static char *lcdportname="«« LCD rendezvous »»";
static char *lcdrexxname="LCDAEMON";

struct lcdparams {
	long width;
	long virtualwidth;
	long height;
	long maxqueuetime;
};
struct lcdqueuedtext {
	STRPTR themessage;
};
struct lcdirect {
	ULONG Command;
	ULONG Data;
};
struct lcdmessage {
	struct Message	lcd_Message;
	long			lcd_Code;
	BYTE			lcd_Priority;
	BYTE			lcd_pad1[3];
	long			lcd_Error;
	long			lcd_Ticks;
	APTR			lcd_Data;
};

/*	LCDscreen for semi-direct screen control and programmable character support.
**
**	DMN : supplied by daemon , read-only to user.
**	USR : supplied by user
**	PRI : private. Don't even think about what this this value might do.
*/

#define LCDSCREEN_MINVERSION	20

struct lcdscreen {
/*

**		Version to identify future versions.
**		Check for your minimum-version before filling out new structure members
**		DMN
*/

	UWORD version;
	UWORD reserved;
/*		
**		Number of characters per screen line. This may be wider than
**		the actual number of characters per line !
**		DMN
*/
	UWORD bufferwidth;
/*
**		Number of lines in the screen buffer.
**		DMN
*/
	UWORD bufferheight;
/*
**		Pointer to private data. Don't touch this field!
**		PRI
*/
	APTR myprivate;
/*
**		Pointer to screen buffer. This gets allocated by LCDaemon, but you
**		must fill it with sensible data.
**		DMN
*/
	UBYTE *screenbuffer;
/*
**		Flags informing what to update.
**		USR
*/
	ULONG ud_flags;
/*
**		Number of bytes per character
**		USR
*/
	UWORD customcharheight;
/*
**		Number of characters defined
**		USR
*/
	UWORD customcharnum;
/*
**		Pointer to the array of programmable characters. You must
**		initialize this pointer to your custom character data.
**		USR
*/
	UBYTE *customchardefs;
};
#define	LCDUPD_DISPLAY			1
#define	LCDUPD_CUSTOMCHARNUM		2
#define	LCDUPD_CUSTOMCHARDEFS	4

#define	LCDPRI_MEMDISPLAY	-64
#define	LCDPRI_APPLICATION	0
#define	LCDPRI_ALERT			64
#define	LCDPRI_VITAL			127
#define	LCDPRI_REMARK			-32
#define	LCDPRI_NEVER			-128

#define	LCDMSG_NONE				0
#define	LCDMSG_ASKPARAMS			1
#define	LCDMSG_QUEUE				2
#define	LCDMSG_ALLOCATELCD		3
#define	LCDMSG_FREELCD			4
#define	LCDMSG_LCDIRECT			5
#define	LCDMSG_ALLOCATEHANDLE	6
#define	LCDMSG_FREEHANDLE		7
#define	LCDMSG_UPDATEHANDLE		8

#define	LCDERR_NONE			0
#define	LCDERR_UNKNOWN		1
#define	LCDERR_NOMEM		2
#define	LCDERR_TOOBUSY		3
#define	LCDERR_YOURFAULT	4

#define	LCDCMD_END		0
#define	LCDCMD_CLS		1
#define	LCDCMD_HOME		2
#define	LCDCMD_CURSDIR	3
#define	LCDCMD_DISPLAY	4
#define	LCDCMD_CURSOR		5
#define	LCDCMD_BLINK		6
#define	LCDCMD_SHIFTD		7
#define	LCDCMD_SHIFTC		8
#define	LCDCMD_GOTOXY		9
#define	LCDCMD_GETXY		10
#define	LCDCMD_DATA		11

#define	LCDRXE_IMGONE 	100

#define	LCDC_ON			TRUE
#define	LCDC_OFF		FALSE
#define	LCDC_YES		TRUE
#define	LCDC_NO			FALSE
#define	LCDC_DATA		TRUE
#define	LCDC_REG		FALSE
#define	LCDC_LEIGHTBITS	TRUE
#define	LCDC_FOURBITS	FALSE
#define	LCDC_TWOLINES	TRUE
#define	LCDC_ONELINE	FALSE
#define	LCDC_TENDOTS	TRUE
#define	LCDC_SEVENDOTS	FALSE
#define	LCDC_RIGHT		TRUE
#define	LCDC_LEFT		FALSE
#define	LCDC_DISPLAY	TRUE
#define	LCDC_CURSOR		FALSE

