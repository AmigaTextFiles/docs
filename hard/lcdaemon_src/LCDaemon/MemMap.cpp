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

//	Memory organization of HD44780 screen lines

#include "AmigaOS.h"
#pragma header

#include <stdlib.h>
#include "MemMap.hpp"

MemoryMapC::MemoryMapC(int Width, int Height, int VirtualWidth, MemoryMapC::MemoryOrganization mo):
	m_Width(Width),
	m_Height(Height),
	m_VirtualWidth(VirtualWidth),
	m_SkipTab(NULL)
{
	m_SkipTabLen=m_VirtualWidth*m_Height;
	ULONG m=VirtualWidth*Height;
	if(!(m_SkipTab=(UBYTE *)AllocMem(m_SkipTabLen,MEMF_CLEAR))) throw MemoryX(m_SkipTabLen,MEMF_CLEAR);
	//	Some basic verification
	switch(mo){
	case e_HalfSkip:
		{
			if(m_Width<=(m_VirtualWidth/2)){
				//	Don't skip visible area
				{for(UWORD x=0;x<m_Width;x++){
					for(UWORD y=0;y<m_Height;y++){
						m_SkipTab[y*m_VirtualWidth+x]=e_DontSkip;
					}
				}}
				//	Just proceed to next DDRAM character if at end of even line
				//	Skip to next line otherwise
				{for(UWORD y=0;y<m_Height;y++){
					m_SkipTab[y*m_VirtualWidth+(m_Width/2)-1]=y*m_VirtualWidth;
					m_SkipTab[y*m_VirtualWidth+m_Width-1]=y*m_VirtualWidth;
				}}
			}else{
				goto linear;
			}
		}
		break;
	case e_Linear:
	default:
		linear:
		{
			for(UWORD x=0;x<m_Width;x++){
				for(UWORD y=0;y<m_Height;y++){
					m_SkipTab[y*m_VirtualWidth+x]=e_DontSkip;	//	No skip for visible area
				}
			}
			for(x=m_Width-1;x<m_VirtualWidth;x++){
				for(UWORD y=0;y<m_Height;y++){
					m_SkipTab[y*m_VirtualWidth+x]=((y+1)%m_Height)*m_VirtualWidth;	//	Skip to next line
				}
			}
		}
	}
}

MemoryMapC::~MemoryMapC(){
	if(m_SkipTab)FreeMem(m_SkipTab,m_SkipTabLen);
}

//	Returns TRUE when the controller length is exceeded.
BOOL MemoryMapC::eoc(int x,int y){
	if(y>=m_Height)return 1;
	if(y==(m_Height-1) && x>=m_Width)return 1;
	return 0;
}

UWORD MemoryMapC::skip(int x, int y){
	return m_SkipTab[(y%m_Height)*m_VirtualWidth+(x%m_Width)];
}

