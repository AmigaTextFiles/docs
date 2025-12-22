#ifndef PRAGMAS_GADTOOLS_LIB_H
#define PRAGMAS_GADTOOLS_LIB_H

#ifndef CLIB_GADTOOLS_PROTOS_H
#include <clib/gadtools_protos.h>
#endif

#pragma amicall(GadToolsBase,0x1e,CreateGadgetA(d0,a0,a1,a2))
#pragma amicall(GadToolsBase,0x24,FreeGadgets(a0))
#pragma amicall(GadToolsBase,0x2a,GT_SetGadgetAttrsA(a0,a1,a2,a3))
#pragma amicall(GadToolsBase,0x30,CreateMenusA(a0,a1))
#pragma amicall(GadToolsBase,0x36,FreeMenus(a0))
#pragma amicall(GadToolsBase,0x3c,LayoutMenuItemsA(a0,a1,a2))
#pragma amicall(GadToolsBase,0x42,LayoutMenusA(a0,a1,a2))
#pragma amicall(GadToolsBase,0x48,GT_GetIMsg(a0))
#pragma amicall(GadToolsBase,0x4e,GT_ReplyIMsg(a1))
#pragma amicall(GadToolsBase,0x54,GT_RefreshWindow(a0,a1))
#pragma amicall(GadToolsBase,0x5a,GT_BeginRefresh(a0))
#pragma amicall(GadToolsBase,0x60,GT_EndRefresh(a0,d0))
#pragma amicall(GadToolsBase,0x66,GT_FilterIMsg(a1))
#pragma amicall(GadToolsBase,0x6c,GT_PostFilterIMsg(a1))
#pragma amicall(GadToolsBase,0x72,CreateContext(a0))
#pragma amicall(GadToolsBase,0x78,DrawBevelBoxA(a0,d0,d1,d2,d3,a1))
#pragma amicall(GadToolsBase,0x7e,GetVisualInfoA(a0,a1))
#pragma amicall(GadToolsBase,0x84,FreeVisualInfo(a0))
#pragma amicall(GadToolsBase,0xae,GT_GetGadgetAttrsA(a0,a1,a2,a3))

#endif  /*  PRAGMAS_GADTOOLS_LIB_H  */
