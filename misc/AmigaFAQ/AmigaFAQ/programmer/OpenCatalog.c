#include <clib/locale_protos.h>
#ifdef AZTEC_C
#include <pragmas/locale_lib.h>
#endif
#if defined(__SASC)  ||  defined(_DCC)  ||  defined(__MAXON__)
#include <pragmas/locale_pragmas.h>
#endif


struct Catalog *OpenCatalog(struct Locale *loc, STRPTR lang, Tag tag, ...)

{ return(OpenCatalogA(loc, lang, (struct TagItem *) &tag));
}
