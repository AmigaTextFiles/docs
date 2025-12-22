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

#ifndef EXTDRIVER_HPP
#define EXTDRIVER_HPP

#include "Classes/Exec/Signals.h"
#include "Classes/Exec/Ports.h"
#include "Classes/Intuition/Requester.h"
#include "ExtSignal.hpp"

/*
** Encapsulation of external driver for C++ autoinit/autoclose
*/
class ExtDriverC {
public:
	ExtDriverC(InfoRequesterC &info,STRPTR libname=NULL);
	STRPTR DriverName(){return name;};
	static void	lcd_pre_message(void);
	static void	lcd_post_message(void);
	static void	lcd_putchar(UBYTE code,BOOL data,ULONG micros,ULONG ctrlmask);
	static void	lcd_delayfor(ULONG micros);
	static void	lcd_visual(ULONG backlight,ULONG contrast);
	static ULONG	lcd_usermessage(MessageC &msg);
	~ExtDriverC();
	static ExtSignalC	*userport;
private:
	static STRPTR name;
	static APTR	hndl;
};
#endif

