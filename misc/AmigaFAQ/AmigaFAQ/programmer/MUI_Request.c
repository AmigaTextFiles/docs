#include <clib/muimaster_protos.h>
#ifdef AZTEC_C
#include <pragmas/muimaster_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/muimaster_pragmas.h>
#endif


LONG MUI_Request(APTR app, APTR win, LONGBITS flags, char *title,
		 char *gadgets, char *format, ...)
{ return(MUI_RequestA(app, win, flags, title, gadgets, format,
		      ((STRPTR)(&format))+sizeof(format)));
}
