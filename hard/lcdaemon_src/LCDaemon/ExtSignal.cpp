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

//	Handler for external library message port

#include "AmigaOS.h"
#pragma header

#include "ExtDriver.hpp"
#include "libraries/LCDDriverMethod.h"

BOOL ExtSignalC::handleMsg(MessageC &msg){
	ULONG result=ExtDriverC::lcd_usermessage(msg);
	if(result==LCDOMERR_QUIT){
		//	Don't initiate a quit ourselves by returning TRUE, just leave it to our CtrlCDispatcherC.
		SetSignal(SIGBREAKF_CTRL_C,SIGBREAKF_CTRL_C);
	}
	return FALSE;
}

