#include <clib/gadtools_protos.h>
#ifdef AZTEC_C
#include <pragmas/gadtools_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/gadtools_pragmas.h>
#endif


struct Menu *CreateMenus(struct NewMenu *nm, Tag tag, ...)

{ return(CreateMenusA(nm, (struct TagItem *) &tag));
}
