#include <clib/asl_protos.h>
#ifdef AZTEC_C
#include <pragmas/asl_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/asl_pragmas.h>
#endif


APTR AllocAslRequestTags(ULONG reqType, Tag tag, ...)

{ return(AllocAslRequest(reqType, (struct TagItem *) &tag));
}
