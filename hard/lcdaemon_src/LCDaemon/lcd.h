/*

						LCDaemon	©1995-97 VOMIT,inc.
						Email: hendrik.devloed@barco.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#ifndef LCD_H
#define LCD_H

#ifndef LCD_NO_PORTNAMES
static char *lcdportname="«« LCD rendezvous »»";
static char *lcdrexxname="LCDAEMON";
#endif

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

#define LCDSCREEN_MINVERSION	22

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

/*
**		New features from V22 onwards:
*/

/*
**		Backlight control (if supported). Set to ~0 to indicate default value,
**		active range varies from 0x0000 to 0xffff.
**		USR
*/
	ULONG backlight;
/*
**		Contrast control (if supported). Set to ~0 to indicate default value,
**		active range varies from 0x0000 to 0xffff.
**		USR
*/
	ULONG contrast;
};
#define	LCDUPD_DISPLAY			1
#define	LCDUPD_CUSTOMCHARNUM		2
#define	LCDUPD_CUSTOMCHARDEFS	4
#define	LCDUPD_OPTICAL			8	/*	backlight or contrast	>=V22	*/

#define	LCDPRI_MEMDISPLAY	-64	/*	"backdrop" displays				*/
#define	LCDPRI_APPLICATION	0		/*	Applications should use this	*/
#define	LCDPRI_ALERT			64
#define	LCDPRI_VITAL			127	/*	System failure indications		*/
#define	LCDPRI_REMARK			-32
#define	LCDPRI_NEVER			-128	/*	Only if there's realy nothing to do	*/

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

/*	Obsoleted
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
*/

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

#endif

