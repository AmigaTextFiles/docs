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

#ifndef MEMORYMAP_HPP
#define MEMORYMAP_HPP

class MemoryMapC {
public:
	enum	MemoryOrganization	{
		e_Linear,
		e_HalfSkip
	};
	enum {e_DontSkip=0xFF};
	MemoryMapC(int Width, int Height, int VirtualWidth, MemoryOrganization mo=e_Linear);
	BOOL eoc(int x,int y);	//	End-of-controller
	UWORD skip(int x, int y);	//	Skip necessary to get to next character
	~MemoryMapC();
private:
	int m_Width;
	int m_Height;
	int m_VirtualWidth;
	UBYTE *m_SkipTab;
	ULONG m_SkipTabLen;
};

#endif
