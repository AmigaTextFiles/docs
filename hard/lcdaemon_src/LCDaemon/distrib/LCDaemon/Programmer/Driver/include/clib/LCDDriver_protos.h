#ifndef CLIB_LCDDRIVER_PROTOS_H
#define CLIB_LCDDRIVER_PROTOS_H

#ifndef LIBRARY
#ifndef LCD_H
#include <lcd.h>
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

APTR AllocLCD(
	struct	lcdparams *lcdpar_a0,
	STRPTR	startup_a1,
	struct timerequest	*timereq_a2
);

VOID FreeLCD(
	APTR	hndl
);

ULONG LCDPreMessage(
	APTR	hndl
);

ULONG LCDPostMessage(
	APTR	hndl
);

ULONG LCDDelayFor(
	APTR	hndl,
	ULONG	micros
);

ULONG LCDPutChar(
	APTR	hndl,
	UBYTE	code_d0,
	BOOL	data_d1,
	ULONG	micros_d2,
	ULONG	ctrlmask_d3
);

STRPTR LCDDriverName(
	APTR	hndl
);

VOID LCDVisual(
	APTR hndl,
	ULONG backlight,
	ULONG contrast
);

ULONG LCDMethod(
	APTR hndl,
	ULONG method,
	APTR param
);

#ifdef __cplusplus
}
#endif

#endif

