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

//	Pool of HD44780 controllers

#include "AmigaOS.h"
#pragma header

#include "ControllerPool.hpp"

ControllerPool::ControllerPool():m_Controllers(0){
}
void ControllerPool::AddController(HD44780 &ctrl){
	if(m_Controllers<MAX_CONTROLLERS){
		controller[m_Controllers++]=&ctrl;
	}else{
		delete &ctrl;
	}
}
ControllerPool::~ControllerPool(){
	while(m_Controllers){
		delete controller[--m_Controllers];
	}
}
HD44780 &ControllerPool::Controller(UWORD num){
	if(num<m_Controllers){
		return *controller[num];
	}else{
		throw;
		return *controller[0];
	}
}

UWORD ControllerPool::m_LinesPerController;

