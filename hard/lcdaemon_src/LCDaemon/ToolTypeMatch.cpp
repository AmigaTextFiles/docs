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

//	Tool type parsing class

#include "AmigaOS.h"
#pragma header

#include <stdlib.h>
#include "ToolTypeMatch.hpp"

ToolTypeMatchC::ToolTypeMatchC(struct WBStartup *StartupMessage) {
	wbs=NULL;dob=NULL;
	if(StartupMessage){
		if(wbs=new WBStartupC(*StartupMessage)){
			dob=new DiskObjectC(wbs->tool().name(),wbs->tool().lock());
			if(!dob->get()){
				delete dob;
				dob=NULL;
			}
		}
	}
}

ToolTypeMatchC::~ToolTypeMatchC(){
	if(dob)delete dob;
	if(wbs)delete wbs;
}

STRPTR ToolTypeMatchC::getStr(STRPTR varname, STRPTR deflt){
	STRPTR result;
	if(dob && (result=dob->findToolType(varname))){
		return result;
	}
	return deflt;
}

LONG ToolTypeMatchC::getNumber(STRPTR varname, LONG deflt){
	STRPTR sresult;
	if(dob && (sresult=dob->findToolType(varname))){
		LONG result;
		STRPTR converted;
		result=strtol(sresult,&converted,10);
		if(converted!=sresult){
			return result;
		}
	}
	return deflt;
}

BOOL ToolTypeMatchC::getSwitch(STRPTR varname){
	STRPTR result=0;
	if(dob)result=dob->findToolType(varname);
	return result?TRUE:FALSE;
}

