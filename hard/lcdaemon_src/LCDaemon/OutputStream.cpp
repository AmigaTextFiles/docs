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

//	A cheap iostream replacement using AmigaOS functions

#include "OutputStream.hpp"

#include "clib/dos_protos.h"

OutputStream& OutputStream::operator<<(STRPTR text){
	PutStr(text);
	return *this;
}

OutputStream& OutputStream::operator<<(ULONG num){
	ULONG *arg=&num;
	VPrintf("%lu",arg);
	return *this;
}

OutputStream& OutputStream::operator<<(OutputStreamNewLine &){
	PutStr("\n");
	return *this;
}

OutputStreamNewLine newline;

