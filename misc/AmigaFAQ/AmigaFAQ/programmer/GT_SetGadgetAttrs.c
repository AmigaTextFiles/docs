#include <clib/gadtools_protos.h>
#ifdef AZTEC_C
#include <pragmas/gadtools_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/gadtools_pragmas.h>
#endif


void GT_SetGadgetAttrs(struct Gadget *gad, struct Window *wnd,
		       struct Requester *req, Tag tag1, ...)
{ GT_SetGadgetAttrsA(gad, wnd, req, (struct TagItem *) &tag1);
}
