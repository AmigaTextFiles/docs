#include <clib/gadtools_protos.h>
#ifdef AZTEC_C
#include <pragmas/gadtools_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/gadtools_pragmas.h>
#endif


BOOL LayoutMenus(struct Menu *menu, APTR visualinfo, Tag tag, ...)

{ return(LayoutMenusA(menu, visualinfo, (struct TagItem *) &tag));
}
