#include <clib/gadtools_protos.h>
#ifdef AZTEC_C
#include <pragmas/gadtools_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/gadtools_pragmas.h>
#endif


struct Gadget *CreateGadget(ULONG kind, struct Gadget *previous,
			    struct NewGadget *newgad, Tag tag, ...)

{ return(CreateGadgetA(kind, previous, newgad, (struct TagItem *) &tag));
}
