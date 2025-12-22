#include <clib/intuition_protos.h>
#ifdef AZTEC_C
#include <pragmas/intuition_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/intuition_pragmas.h>
#endif


LONG EasyRequest(struct Window *wnd, struct EasyStruct *es,
		 ULONG *IDCMP_ptr, ...)
{ return(EasyRequestArgs(wnd, es, IDCMP_ptr,
			 ((STRPTR) &IDCMP_ptr)+sizeof(IDCMP_ptr)));
}
