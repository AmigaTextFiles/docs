#ifndef PRAGMAS_GADTOOLS_PRAGMAS_H
#define PRAGMAS_GADTOOLS_PRAGMAS_H

#ifndef CLIB_GADTOOLS_PROTOS_H
#include <clib/gadtools_protos.h>
#endif

extern struct Library *GadToolsBase;

#pragma libcall GadToolsBase CreateGadgetA 1e A98004
#pragma libcall GadToolsBase FreeGadgets 24 801
#pragma libcall GadToolsBase GT_SetGadgetAttrsA 2a BA9804
#pragma libcall GadToolsBase CreateMenusA 30 9802
#pragma libcall GadToolsBase FreeMenus 36 801
#pragma libcall GadToolsBase LayoutMenuItemsA 3c A9803
#pragma libcall GadToolsBase LayoutMenusA 42 A9803
#pragma libcall GadToolsBase GT_GetIMsg 48 801
#pragma libcall GadToolsBase GT_ReplyIMsg 4e 901
#pragma libcall GadToolsBase GT_RefreshWindow 54 9802
#pragma libcall GadToolsBase GT_BeginRefresh 5a 801
#pragma libcall GadToolsBase GT_EndRefresh 60 0802
#pragma libcall GadToolsBase GT_FilterIMsg 66 901
#pragma libcall GadToolsBase GT_PostFilterIMsg 6c 901
#pragma libcall GadToolsBase CreateContext 72 801
#pragma libcall GadToolsBase DrawBevelBoxA 78 93210806
#pragma libcall GadToolsBase GetVisualInfoA 7e 9802
#pragma libcall GadToolsBase FreeVisualInfo 84 801
#pragma libcall GadToolsBase GT_GetGadgetAttrsA ae BA9804

#endif  /*  PRAGMAS_GADTOOLS_PRAGMAS_H  */
