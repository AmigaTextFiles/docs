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

// Hitachi HD44780 controller module

#include "AmigaOS.h"
#pragma header

#include "hd44780.hpp"
#include "ExtDriver.hpp"

//	Imported functions from port driver
//extern "C" void	lcd_delayfor(ULONG);
//extern "C" void	lcd_putchar(UBYTE,BOOL,ULONG,ULONG);


ULONG HD44780::allcontrollers;
HD44780::HD44780(ULONG index,ULONG initflags){
	static ULONG dt[HDCOMMANDS]={1640,1640,40,40,40,40,40,40};
	lcdnummask=1L<<index;
	allcontrollers=(lcdnummask<<1)-1;
	for(register int i=0;i<HDCOMMANDS;i++)delaytime[i]=dt[i];
	flushcmdcache();
	lcd_InitialSet(1,0,0);
	flushcmdcache();
	lcd_InitialSet(1,0,0);
	flushcmdcache();
	lcd_InitialSet(1,0,0);
	flushcmdcache();
/*	ExtDriverC::lcd_putchar(0x30,REG,4100*SAFETY);
	ExtDriverC::lcd_putchar(0x30,REG,100*SAFETY);
	ExtDriverC::lcd_putchar(0x30,REG,100*SAFETY);
*/
	lcd_InitialSet(1,initflags&HD44780_INIT_TWOLINES,initflags&HD44780_INIT_TALLCHARS);
	lcd_DisplayMode(1,0,0);
	lcd_Clear();
	lcd_ShiftMode(1,0);
	//	Clear font cache
	lcd_CGRAMAddress(0);
	for(i=0;i<64;i++){
		fontcache[i]=~0;
		lcd_WriteData(0);
	}
	lines=(initflags&HD44780_INIT_TWOLINES)?2:1;
	characters=40;
	lcd_Clear();
}
void HD44780::lcd_Clear(void){
	virtddaddr=actddaddr=0;virtcgaddr=actcgaddr=~0;
	for(register ULONG i=0;i<128;i++)datacache[i]=' ';
	ExtDriverC::lcd_putchar(0x01,LCDC_REG,delaytime[0],lcdnummask);
}
void HD44780::lcd_CursorHome(void){
	virtddaddr=actddaddr=0;virtcgaddr=actcgaddr=~0;
	ExtDriverC::lcd_putchar(0x02,LCDC_REG,delaytime[1],lcdnummask);
}
void HD44780::lcd_ShiftMode(ULONG incdec, ULONG shift){
	UBYTE opcode=0x04;
	if(incdec)opcode|=0x02;
	if(shift)opcode|=0x01;
	if(currentval[2]!=opcode){
		ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[2],lcdnummask);
		currentval[2]=opcode;
	}
}
void HD44780::lcd_DisplayMode(ULONG displayon, ULONG cursoron, ULONG blinkon){
	UBYTE opcode=0x08;
	if(displayon)opcode|=0x04;
	if(cursoron)opcode|=0x02;
	if(blinkon)opcode|=0x01;
	if(currentval[3]!=opcode){
		ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[3],lcdnummask);
		currentval[3]=opcode;
	}
}
void HD44780::lcd_DisplayShift(ULONG displayshift, ULONG right){
	UBYTE opcode=0x10;
	if(displayshift)opcode|=0x08;
	if(right)opcode|=0x04;
	if(currentval[4]!=opcode){
		ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[4],lcdnummask);
		currentval[4]=opcode;
	}
}
void HD44780::lcd_InitialSet(ULONG numbits, ULONG numlines, ULONG numdots){
	UBYTE opcode=0x20;
	if(numbits)opcode|=0x10;
	if(numlines)opcode|=0x08;
	if(numdots)opcode|=0x04;
	if(currentval[5]!=opcode){
		ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[5],lcdnummask);
		currentval[5]=opcode;
	}
}
void HD44780::lcd_CGRAMAddress(ULONG address){
	UBYTE opcode=0x40;
	address&=0x3f;
	actcgaddr=virtcgaddr=address;actddaddr=virtddaddr=~0;
	opcode|=address;
	ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[6],allcontrollers);	//	Update all controllers at once.
}
void HD44780::lcd_DDRAMAddress(ULONG address){
	UBYTE opcode=0x80;
	address&=0x7f;
	actddaddr=virtddaddr=address;actcgaddr=virtcgaddr=~0;
	opcode|=address;
	ExtDriverC::lcd_putchar(opcode,LCDC_REG,delaytime[7],lcdnummask);
}
void HD44780::flushcmdcache(void){
	for(int i=0;i<HDCOMMANDS;i++){
		currentval[i]=~0;
	}
	ExtDriverC::lcd_delayfor(15000);
}
void HD44780::lcd_WriteData(UBYTE data){
	if(actcgaddr!=(UWORD)~0){
		if(virtcgaddr<64){
			if(fontcache[virtcgaddr]!=data){
				if(virtcgaddr!=actcgaddr){
					lcd_CGRAMAddress(virtcgaddr);
				}
				ExtDriverC::lcd_putchar(data,LCDC_DATA,delaytime[7],allcontrollers);	//	Write character data to all controllers.
				fontcache[actcgaddr]=data;
				actcgaddr++;
			}
		}
		virtcgaddr++;
	}else{
		if(virtddaddr<128){
			if(datacache[virtddaddr]!=data){
				if(virtddaddr!=actddaddr){
					lcd_DDRAMAddress(virtddaddr);
				}
				ExtDriverC::lcd_putchar(data,LCDC_DATA,delaytime[7],lcdnummask);
				datacache[actddaddr]=data;
				actddaddr++;
			}
			virtddaddr++;
		}
	}
}
void HD44780::lcd_FlushCGCache(void){
	
}
void HD44780::lcd_FlushDDCache(void){
	
}

