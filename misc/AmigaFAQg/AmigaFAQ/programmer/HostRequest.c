#include <clib/envoy_protos.h>
#ifdef AZTEC_C
#include <pragmas/envoy_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/envoy_pragmas.h>
#endif


BOOL HostRequest(Tag tag, ...)

{ return(HostRequestA((struct TagItem *) &tag));
}
