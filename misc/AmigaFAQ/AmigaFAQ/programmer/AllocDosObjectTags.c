#include <clib/dos_protos.h>
#include <utility/tagitem.h>
#ifdef AZTEC_C
#include <pragmas/dos_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/dos_pragmas.h>
#endif


void *AllocDosObjectTags(ULONG type, Tag tag1, ...)

{ return(AllocDosObject(type, (struct TagItem *) &tag1));
}
