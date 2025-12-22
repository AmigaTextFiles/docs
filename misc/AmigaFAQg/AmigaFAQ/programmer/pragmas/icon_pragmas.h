#ifndef PRAGMAS_ICON_PRAGMAS_H
#define PRAGMAS_ICON_PRAGMAS_H

#ifndef CLIB_ICON_PROTOS_H
#include <clib/icon_protos.h>
#endif

extern struct Library *IconBase;

#pragma libcall IconBase FreeFreeList 36 801
#pragma libcall IconBase AddFreeList 48 A9803
#pragma libcall IconBase GetDiskObject 4e 801
#pragma libcall IconBase PutDiskObject 54 9802
#pragma libcall IconBase FreeDiskObject 5a 801
#pragma libcall IconBase FindToolType 60 9802
#pragma libcall IconBase MatchToolValue 66 9802
#pragma libcall IconBase BumpRevision 6c 9802
#pragma libcall IconBase GetDefDiskObject 78 001
#pragma libcall IconBase PutDefDiskObject 7e 801
#pragma libcall IconBase GetDiskObjectNew 84 801
#pragma libcall IconBase DeleteDiskObject 8a 801

#endif  /*  PRAGMAS_ICON_PRAGMAS_H  */
