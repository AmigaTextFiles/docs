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

#define LCDPRI_MEMDISPLAY	-64
#define LCDPRI_APPLICATION	0
#define	LCDPRI_ALERT		64
#define	LCDPRI_VITAL		127
#define	LCDPRI_REMARK		-32
#define LCDPRI_NEVER		-128

#define LCDMSG_NONE			0
#define LCDMSG_ASKPARAMS	1
#define LCDMSG_QUEUE		2
#define LCDMSG_ALLOCATELCD	3
#define LCDMSG_FREELCD		4
#define LCDMSG_LCDIRECT		5

#define LCDERR_NONE			0
#define LCDERR_UNKNOWN		1
#define LCDERR_NOMEM		2
#define LCDERR_TOOBUSY		3
#define LCDERR_YOURFAULT	4

#define LCDCMD_END		0
#define LCDCMD_CLS		1
#define LCDCMD_HOME		2
#define LCDCMD_CURSDIR	3
#define LCDCMD_DISPLAY	4
#define LCDCMD_CURSOR	5
#define LCDCMD_BLINK	6
#define LCDCMD_SHIFTD	7
#define LCDCMD_SHIFTC	8
#define LCDCMD_GOTOXY	9
#define LCDCMD_GETXY	10
#define LCDCMD_DATA		11

#define LCDRXE_IMGONE 	100

#define ON TRUE
#define OFF FALSE
#define YES TRUE
#define NO FALSE
#define DATA TRUE
#define REG FALSE
#define EIGHTBITS TRUE
#define FOURBITS FALSE
#define TWOLINES TRUE
#define ONELINE FALSE
#define TENDOTS TRUE
#define SEVENDOTS FALSE
#define RIGHT TRUE
#define LEFT FALSE
#define DISPLAY TRUE
#define CURSOR FALSE
