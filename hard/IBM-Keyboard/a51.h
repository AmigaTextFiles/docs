#include <stdio.h>
#include <string.h>

short		mem[32768];
char		s[80];
char		buffer[80];
char		hexstr[7];
char		name[80];
char		left[80];
char		basename[80];
char		c;
int		addr,line,lval,mi,pass,pos,rval,realvalue,value;
int		lop,rel,rop,ln,hexsflag;
FILE 		*f,*f_lst,*f_hex;
struct		taglist {
	char	tag[80];
	int	value;
	struct	taglist *next;
	};
struct taglist	*tag_list;
typedef	struct taglist ELEM;
typedef	ELEM *LINK;

