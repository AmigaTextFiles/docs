#include <clib/gadtools_protos.h>
#ifdef AZTEC_C
#include <pragmas/gadtools_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/gadtools_pragmas.h>
#endif


APTR GetVisualInfo(struct Screen *screen, Tag tag, ...)

{ return(GetVisualInfoA(screen, (struct TagItem *) &tag));
}
