#ifndef _INCLUDE_PRAGMA_LCDDRIVER_LIB_H
#define _INCLUDE_PRAGMA_LCDDRIVER_LIB_H

#ifndef CLIB_LCDDRIVER_PROTOS_H
#include <clib/LCDDriver_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(LCDDriverBase,0x01E,AllocLCD(a0,a1,a2))
#pragma amicall(LCDDriverBase,0x024,FreeLCD(a0))
#pragma amicall(LCDDriverBase,0x02A,LCDPutChar(a0,d0,d1,d2,d3))
#pragma amicall(LCDDriverBase,0x030,LCDDelayFor(a0,d0))
#pragma amicall(LCDDriverBase,0x036,LCDPreMessage(a0))
#pragma amicall(LCDDriverBase,0x03C,LCDPostMessage(a0))
#pragma amicall(LCDDriverBase,0x042,LCDDriverName(a0))
#pragma amicall(LCDDriverBase,0x048,LCDVisual(a0,d0,d1))
#pragma amicall(LCDDriverBase,0x04E,LCDMethod(a0,d0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma libcall LCDDriverBase AllocLCD             01E A9803
#pragma libcall LCDDriverBase FreeLCD              024 801
#pragma libcall LCDDriverBase LCDPutChar           02A 3210805
#pragma libcall LCDDriverBase LCDDelayFor          030 0802
#pragma libcall LCDDriverBase LCDPreMessage        036 801
#pragma libcall LCDDriverBase LCDPostMessage       03C 801
#pragma libcall LCDDriverBase LCDDriverName        042 801
#pragma libcall LCDDriverBase LCDVisual            048 10803
#pragma libcall LCDDriverBase LCDMethod            04E 90803
#endif

#endif	/*  _INCLUDE_PRAGMA_LCDDRIVER_LIB_H  */