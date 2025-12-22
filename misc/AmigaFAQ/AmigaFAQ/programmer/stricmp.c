#include <string.h>
#include <ctype.h>

/*
    Case insensitive strcmp
*/
int stricmp(const char *_s1, const char *_s2)

{ int c1, c2;

  do
  { c1 = tolower((int) *_s1++);
    c2 = tolower((int) *_s2++);
  }
  while(c1  &&  c1 == c2);
  return(c1-c2);
}

/*
    Case insensitive strncmp
*/
int strnicmp(const char *_s1, const char *_s2, size_t _n)

{ int c1, c2;

  while(_n--)
  { c1 = tolower((int) *_s1++);
    c2 = tolower((int) *_s2++);
    if (!c1  ||  c1 != c2)
    { return(c1-c2);
    }
  }
  return(0);
}
