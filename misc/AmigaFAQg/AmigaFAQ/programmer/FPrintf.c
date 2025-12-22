#include <clib/dos_protos.h>
#ifdef AZTEC_C
#include <pragmas/dos_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/dos_pragmas.h>
#endif


LONG FPrintf(BPTR fh, STRPTR str, ...)

{ return(VFPrintf(fh, str, ((STRPTR) &str)+sizeof(str)));
}
