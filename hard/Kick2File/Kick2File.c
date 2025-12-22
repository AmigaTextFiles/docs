
// Includes
#include <exec/types.h>
#include <pragma/dos_lib.h>
#include <dos/dos.h>
#include <iostream.h>
#include <stdlib.h>


// Konstanten
#define SMALLMAGIC 0x11114ef9
#define SMALLROM   0x00040000
#define BIGMAGIC   0x11144ef9
#define BIGROM     0x00080000


// Strukturen
struct romfileheader
{
  ULONG alwaysnil;
  ULONG romsize;
};


// globale Variablen
char *versi = "$VER: Kick2File 1.0 (11-Jun-1996) © by Maik \"BLiZZeR\" Schreiber [FREEWARE]";


// Programm
int main(int argc, char *argv[])
{
  if (argc != 2)
    cout << "Usage: Kick2File <filename>\n";
  else if (((char *) argv[1])[0] == '?')
    cout << "Usage: Kick2File <filename>\n";
  else
  {
    int    ret  = RETURN_OK;
    ULONG *base = (ULONG *) 0x00f80000,
           size;

    if (base[0] != BIGMAGIC)
      base = (ULONG *) 0x00fc0000;

    switch (base[0])
    {
      case SMALLMAGIC:
        size = SMALLROM;
        break;
      case BIGMAGIC:
        size = BIGROM;
        break;
      default:
        size = NULL;
    };
    if (size)
    {
      struct romfileheader rfh = {NULL, size};
      BPTR   handle;
      ULONG  len;

      cout << "\033[1mKick2File 1.0 - Copyright © 11-Jun-1996 by Maik Schreiber [FREEWARE]\033[0m\n\n\
Writing ROM data (" << sizeof(struct romfileheader) + size << " Bytes)...\n";

      if (handle = Open(argv[1], MODE_NEWFILE))
      {
        len = Write(handle, &rfh, sizeof(struct romfileheader));
        len += Write(handle, base, size);
        Close(handle);
        if (len != (sizeof(struct romfileheader) + size))
        {
          cout << "\n\033[1mCouldn't write ROM data!\033[0m\n";
          ret = RETURN_FAIL;
        };
      };
      else
      {
        cout << "\n\033[1mCouldn't open file!\033[0m\n";
        ret = RETURN_FAIL;
      };
    };
    else
    {
      cout << "\n\033[1;33mUnknown ROM size!\033[0m\n";
      ret = RETURN_FAIL;
    };
    exit(ret);
  };
};

