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

//	These headers are compiled into a precompiled header file for fast inclusion

#include <exec/types.h>
#include <dos/dos.h>
#include <pragma/all_lib.h>
#include <devices/timer.h>
#include <hardware/cia.h>
#include <rexx/rxslib.h>
#include <rexx/errors.h>

#include <Classes/Exceptions/Exceptions.h>
#include <Classes/DataStructures/String.h>
#include <Classes/Exec/Lists.h>
#include <Classes/Exec/Libraries.h>
#include <Classes/Exec/Devices.h>
#include <Classes/Exec/Signals.h>
#include <Classes/DOS/Arguments.h>
#include <Classes/Intuition/Requester.h>

