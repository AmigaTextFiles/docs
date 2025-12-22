/****************************************************************
   This file was created automatically by `FlexCat V1.3'
   Do NOT edit by hand!
****************************************************************/

#ifndef SysMon_CAT_H
#define SysMon_CAT_H


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif	/*  !EXEC_TYPES_H	    */
#ifndef LIBRARIES_LOCALE_H
#include <libraries/locale.h>
#endif	/*  !LIBRARIES_LOCALE_H     */


/*  Prototypes	*/
extern void OpenSysMonCatalog(struct Locale *, STRPTR);
extern void CloseSysMonCatalog(void);
extern STRPTR GetSysMonString(APTR);

/*  Definitions */
extern const APTR _msgNoMemory;
#define msgNoMemory ((APTR) &_msgNoMemory)
extern const APTR _msgErrorTitle;
#define msgErrorTitle ((APTR) &_msgErrorTitle)
extern const APTR _msgErrorFormat;
#define msgErrorFormat ((APTR) &_msgErrorFormat)
extern const APTR _msgErrorGadgets;
#define msgErrorGadgets ((APTR) &_msgErrorGadgets)
extern const APTR _msgLCDUnavailable;
#define msgLCDUnavailable ((APTR) &_msgLCDUnavailable)
extern const APTR _msgArguments;
#define msgArguments ((APTR) &_msgArguments)

#endif /*   !SysMon_CAT_H  */
