/****************************************************************
   Do NOT edit by hand!
****************************************************************/

#include <clib/locale_protos.h>
#include <pragmas/locale_pragmas.h>

static LONG SysMon_Version = 0;
static const STRPTR SysMon_BuiltInLanguage = (STRPTR) "english";

struct FC_Type
{   LONG   ID;
    STRPTR Str;
};


const struct FC_Type _msgNoMemory = { 0, "Out of memory" };
const struct FC_Type _msgErrorTitle = { 1, "SysMon error:" };
const struct FC_Type _msgErrorFormat = { 2, "Sysmon failed:\n%s!" };
const struct FC_Type _msgErrorGadgets = { 3, "Terminate" };
const struct FC_Type _msgLCDUnavailable = { 4, "LCDaemon is not responding" };
const struct FC_Type _msgArguments = { 5, "Incorrect command line arguments" };
extern struct Library *LocaleBase;


static struct Catalog *SysMon_Catalog = NULL;

void OpenSysMonCatalog(struct Locale *loc, STRPTR language)
{ LONG tag, tagarg;
  extern void CloseSysMonCatalog(void);

  CloseSysMonCatalog(); /* Not needed if the programmer pairs OpenSysMonCatalog
		       and CloseSysMonCatalog right, but does no harm.  */

  if (LocaleBase != NULL  &&  SysMon_Catalog == NULL)
  { if (language == NULL)
    { tag = TAG_IGNORE;
    }
    else
    { tag = OC_Language;
      tagarg = (LONG) language;
    }
    SysMon_Catalog = OpenCatalog(loc, (STRPTR) "SysMon.catalog",
				OC_BuiltInLanguage, SysMon_BuiltInLanguage,
				tag, tagarg,
				OC_Version, SysMon_Version,
				TAG_DONE);
  }
}

void CloseSysMonCatalog(void)
{ if (LocaleBase != NULL)
  { CloseCatalog(SysMon_Catalog);
  }
  SysMon_Catalog = NULL;
}

STRPTR GetSysMonString(APTR fcstr)
{ STRPTR defaultstr;
  LONG strnum;

  strnum = ((struct FC_Type *) fcstr)->ID;
  defaultstr = ((struct FC_Type *) fcstr)->Str;

  return(SysMon_Catalog ? GetCatalogStr(SysMon_Catalog, strnum, defaultstr) :
		      defaultstr);
}
