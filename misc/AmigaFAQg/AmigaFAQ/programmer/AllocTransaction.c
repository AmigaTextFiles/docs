#include <clib/nipc_protos.h>
#ifdef AZTEC_C
#include <pragmas/nipc_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/nipc_pragmas.h>
#endif


struct Transaction *AllocTransaction(Tag tag1, ...)

{ return(AllocTransactionA((struct TagItem *) &tag1));
}
