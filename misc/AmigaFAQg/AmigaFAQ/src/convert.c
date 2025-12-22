#include <stdlib.h>
#include <stdio.h>
#include <string.h>


void main(int argc, char *argv[])

{ int c;

  while ((c = getchar())  !=  EOF)
    { if (c == (unsigned char) '\344')
	{ putchar('a');
	  putchar('e');
	}
      else if (c == (unsigned char) '\366')
	{ putchar('o');
	  putchar('e');
	}
      else if (c == (unsigned char) '\374')
	{ putchar('u');
	  putchar('e');
	}
      else if (c == (unsigned char) '\304')
	{ putchar('A');
	  putchar('e');
	}
      else if (c == (unsigned char) '\326')
	{ putchar('O');
          putchar('e');
	}
      else if (c == (unsigned char) '\334')
	{ putchar('U');
	  putchar('e');
	}
      else if (c == (unsigned char) '\337')
	{ putchar('s');
          putchar('s');
	}
      else
	{ putchar(c);
	}
    }
}
