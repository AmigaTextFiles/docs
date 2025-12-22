#ifndef EXTDRIVER_HPP
#define EXTDRIVER_HPP

/*
** Encapsulation of external driver for C++ autoinit/autoclose
*/

#include "DriverLib/include/LCDDriverBase.h"

class ExtDriverC {
public:
	ExtDriverC(InfoRequesterC &info,STRPTR libname=NULL);
	STRPTR DriverName(){return name;};
	~ExtDriverC();
private:
	STRPTR m_libname;
	STRPTR m_name;
	struct LCDDriverBase *LCDDriverBase;
};
#endif

