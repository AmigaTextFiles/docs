#ifndef PRAGMAS_TIMER_LIB_H
#define PRAGMAS_TIMER_LIB_H

#ifndef CLIB_TIMER_PROTOS_H
#include <clib/timer_protos.h>
#endif

#pragma amicall(TimerBase,0x2a,AddTime(a0,a1))
#pragma amicall(TimerBase,0x30,SubTime(a0,a1))
#pragma amicall(TimerBase,0x36,CmpTime(a0,a1))
#pragma amicall(TimerBase,0x3c,ReadEClock(a0))
#pragma amicall(TimerBase,0x42,GetSysTime(a0))

#endif  /*  PRAGMAS_TIMER_LIB_H  */
