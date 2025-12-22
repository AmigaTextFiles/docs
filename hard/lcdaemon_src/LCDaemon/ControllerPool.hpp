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

#ifndef CONTROLLERPOOL_HPP
#define CONTROLLERPOOL_HPP

#include "hd44780.hpp"

//	Pool of HD44780 controllers

#define MAX_CONTROLLERS 4

class ControllerPool{
public:
	ControllerPool();
	~ControllerPool();
	void AddController(HD44780 &ctrl);
	UWORD numControllers(){return m_Controllers;};
	HD44780 &Controller(UWORD num);
	static UWORD m_LinesPerController;
private:
	UWORD m_Controllers;
	HD44780 *controller[MAX_CONTROLLERS];
};

#endif
