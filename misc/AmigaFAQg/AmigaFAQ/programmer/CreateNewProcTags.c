#include <clib/dos_protos.h>
#include <utility/tagitem.h>
#ifdef AZTEC_C
#include <pragmas/dos_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/dos_pragmas.h>
#endif


struct Process *CreateNewProcTags(Tag tag, ...)

{ return(CreateNewProc((struct TagItem *) &tag));
}
