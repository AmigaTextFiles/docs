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

#ifndef HD44780_HPP
#define HD44780_HPP

#include <exec/types.h>
#include "lcd.h"

/*
** HD44780 chipset controller
*/
#define HDCOMMANDS 8
#define HD44780_INIT_TWOLINES	1
#define HD44780_INIT_TALLCHARS	2
class HD44780 {
public:
	HD44780(ULONG index=0,ULONG initflags=0);
	/*	Command set	*/
	void lcd_Clear(void);
	void lcd_CursorHome(void);
	void lcd_Clear(void);
	void lcd_CursorHome(void);
	void lcd_ShiftMode(ULONG incdec, ULONG shift);
	void lcd_DisplayMode(ULONG displayon, ULONG cursoron, ULONG blinkon);
	void lcd_DisplayShift(ULONG displayshift, ULONG right);
	void lcd_InitialSet(ULONG numbits, ULONG numlines, ULONG numdots);
	void lcd_CGRAMAddress(ULONG address);
	void lcd_DDRAMAddress(ULONG address);
	void lcd_WriteData(UBYTE data);
	void lcd_FlushCGCache(void);
	void lcd_FlushDDCache(void);
//	static HD44780 *controller[];
//	static UWORD controllers;
private:
	void flushcmdcache(void);
	UBYTE datacache[128],fontcache[64];
	UWORD virtcgaddr,virtddaddr,actcgaddr,actddaddr;
	ULONG lcdnummask;
	static ULONG allcontrollers;
	ULONG lines,characters;
	UBYTE currentval[HDCOMMANDS];
	ULONG delaytime[HDCOMMANDS];
};
#endif

