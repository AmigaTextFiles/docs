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

#ifndef ENVVAR_HPP
#define ENVVAR_HPP

#define MAXALLOCATED	32

class EnvVarC{
public:
	EnvVarC();
	~EnvVarC();
	STRPTR getStr(STRPTR varname,STRPTR deflt=NULL);
	LONG getNumber(STRPTR varname, LONG deflt=0L);
	BOOL getSwitch(STRPTR varname);
private:
	STRPTR getVar(STRPTR varname);
	void freeVar(void);
	STRPTR allocated[MAXALLOCATED];
	int numallocated;
};

#endif

