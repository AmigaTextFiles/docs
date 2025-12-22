#include <clib/muimaster_protos.h>
#ifdef AZTEC_C
#include <pragmas/muimaster_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/muimaster_pragmas.h>
#endif


APTR MUI_NewObject(char *class, Tag tag, ...)

{ return(MUI_NewObjectA(class, (struct TagItem *) &tag));
}
