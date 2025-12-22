#ifndef PRAGMAS_MUIMASTER_LIB_H
#define PRAGMAS_MUIMASTER_LIB_H

#ifndef CLIB_MUIMASTER_PROTOS_H
#include <clib/muimaster_protos.h>
#endif

#pragma amicall(MUIMasterBase,0x1e,MUI_NewObjectA(a0,a1))
#pragma amicall(MUIMasterBase,0x24,MUI_DisposeObject(a0))
#pragma amicall(MUIMasterBase,0x2a,MUI_RequestA(d0,d1,d2,a0,a1,a2,a3))
#pragma amicall(MUIMasterBase,0x30,MUI_AllocAslRequest(d0,a0))
#pragma amicall(MUIMasterBase,0x36,MUI_AslRequest(a0,a1))
#pragma amicall(MUIMasterBase,0x3c,MUI_FreeAslRequest(a0))
#pragma amicall(MUIMasterBase,0x42,MUI_Error())
#pragma amicall(MUIMasterBase,0x48,MUI_SetError(d0))
#pragma amicall(MUIMasterBase,0x4e,MUI_GetClass(a0))
#pragma amicall(MUIMasterBase,0x54,MUI_FreeClass(a0))
#pragma amicall(MUIMasterBase,0x5a,MUI_RequestIDCMP(a0,d0))
#pragma amicall(MUIMasterBase,0x60,MUI_RejectIDCMP(a0,d0))
#pragma amicall(MUIMasterBase,0x66,MUI_Redraw(a0,d0))

#endif  /*  PRAGMAS_MUIMASTER_LIB_H  */
