/*
**
**      definition of LCDDriverBase
**
*/

#ifndef LCD_LCDDRIVERBASE_H
#define LCD_LCDDRIVERBASE_H

#include <exec/libraries.h>
#include <exec/execbase.h>

struct LCDDriverBase
{
	/*	Private	*/
	struct Library		lcddrvb_LibNode;
	APTR					lcddrvb_SegList;
	struct ExecBase		*lcddrvb_SysBase;
	APTR					lcddrvb_PrivateData;
};

#endif /* LCD_LCDDRIVERBASE_H */
