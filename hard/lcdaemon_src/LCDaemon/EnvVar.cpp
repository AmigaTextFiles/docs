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

//	Environment variable parsing class

#include "AmigaOS.h"
#pragma header

#include "EnvVar.hpp"

#include <stdlib.h>

#define BUFLEN	128

EnvVarC::EnvVarC(){
	numallocated=0;
}

EnvVarC::~EnvVarC(){
	while(numallocated--){
		if(allocated[numallocated])FreeVec(allocated[numallocated]);
	}
}

STRPTR EnvVarC::getStr(STRPTR varname,STRPTR deflt){
	STRPTR buffer;
	if(buffer=getVar(varname)){
		return buffer;
	}
	return deflt;
}

LONG EnvVarC::getNumber(STRPTR varname, LONG deflt){
	STRPTR buffer;
	if(buffer=getVar(varname)){
		LONG val;
		STRPTR last;
		val=strtol(buffer,&last,10);
		freeVar();
		if(last!=buffer){
			return val;
		}
	}
	return deflt;
}

BOOL EnvVarC::getSwitch(STRPTR varname){
	LONG sw=getNumber(varname);
	return sw?TRUE:FALSE;
}

//	Private

STRPTR EnvVarC::getVar(STRPTR varname){
	LONG length;
	STRPTR buffer;
	if(allocated[numallocated]=buffer=(STRPTR)AllocVec(BUFLEN,MEMF_CLEAR)){
		numallocated++;
		if((length=GetVar(varname,buffer,BUFLEN,GVF_GLOBAL_ONLY))>0){
			buffer[length]=0;
			return buffer;
		}
	}
	return NULL;
}
void EnvVarC::freeVar(void){
	FreeVec(allocated[--numallocated]);
}

