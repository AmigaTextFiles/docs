#include <clib/intuition_protos.h>
#ifdef AZTEC_C
#include <pragmas/intuition_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/intuition_pragmas.h>
#endif


struct Screen *OpenScreenTags(struct NewScreen *ns, Tag tag, ...)

{ return(OpenScreenTagList(ns, (struct TagItem *) &tag));
}
