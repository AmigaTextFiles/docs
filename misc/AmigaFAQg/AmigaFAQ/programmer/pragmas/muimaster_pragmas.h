#ifndef PRAGMAS_MUIMASTER_PRAGMAS_H
#define PRAGMAS_MUIMASTER_PRAGMAS_H

#ifndef CLIB_MUIMASTER_PROTOS_H
#include <clib/muimaster_protos.h>
#endif

extern struct Library *MUIMasterBase;

#pragma libcall MUIMasterBase MUI_NewObjectA 1e 9802
#pragma libcall MUIMasterBase MUI_DisposeObject 24 801
#pragma libcall MUIMasterBase MUI_RequestA 2a BA9821007
#pragma libcall MUIMasterBase MUI_AllocAslRequest 30 8002
#pragma libcall MUIMasterBase MUI_AslRequest 36 9802
#pragma libcall MUIMasterBase MUI_FreeAslRequest 3c 801
#pragma libcall MUIMasterBase MUI_Error 42 00
#pragma libcall MUIMasterBase MUI_SetError 48 001
#pragma libcall MUIMasterBase MUI_GetClass 4e 801
#pragma libcall MUIMasterBase MUI_FreeClass 54 801
#pragma libcall MUIMasterBase MUI_RequestIDCMP 5a 0802
#pragma libcall MUIMasterBase MUI_RejectIDCMP 60 0802
#pragma libcall MUIMasterBase MUI_Redraw 66 0802

#endif  /*  PRAGMAS_MUIMASTER_PRAGMAS_H  */
