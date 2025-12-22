#include <clib/intuition_protos.h>
#ifdef AZTEC_C
#include <pragmas/intuition_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/intuition_pragmas.h>
#endif


ULONG SetAttrs(APTR Object, Tag tag, ...)

{ return(SetAttrsA(Object, (struct TagItem *) &tag));
}
