#include "a51.h"
void convert();
void hexs();

void cleanexit(t)
char t[80];
{
	int x;
	LINK tl;
		tl=tag_list;
		x=0;
		hexsflag=0;
		while (tl!=(LINK) NULL)
		{
			if (x==0) fprintf(f_lst,"\n");
			else fprintf(f_lst,"\t");
			hexs(tl->value);
			fprintf(f_lst,"%s\t%s",tl->tag,hexstr);
			tl=tl->next;
		}
		fprintf(f_lst,"\n\n");
		fclose(f_lst);
	printf("****%d\t%s\n",line,buffer);
	printf("ERROR:%s\n",t);
	exit();
}

void warn(t)
char t[80];
{
	printf("++++%d\t%s\n",line,buffer);
	printf("WARNING:%s\n",t);
	return;
}

void strnullcpy(t,u,n)
char t[80];
char u[80];
int n;
{
	strncpy(t,u,n);
	t[n]='\0';
	return;
}

void hack(n)
int n;
{
	int x;
	for (x=0;x<=80;x++)
		s[x]=s[x+n];
	pos-=n;
	return;
}

char hexc(n)
int n;
{
	if ((n+=48)>57) n+=7;
	return((char) n);
}

void hexs(l)
long l;
{
	long m;
	char t[7];
	m=l;
	t[0]=hexc(m/1048576);
	m%=1048576;
	t[1]=hexc(m/65536);
	m%=65536;
	t[2]=hexc(m/4096);
	m%=4096;
	t[3]=hexc(m/256);
	m%=256;
	t[4]=hexc(m/16);
	m%=16;
	t[5]=hexc(m);
	t[6]='\0';
	if (l>65535) {strcpy(hexstr,t);return;}
	if ((l>255)||(hexsflag==1)) {strcpy(hexstr,&t[2]);return;}
	strcpy(hexstr,&t[4]);
	return;
}

void showcode()
{
	int x,y;
	int flag;
	char filename[80];
	char longstr[80];
	strcpy(filename,basename);
	f_hex=fopen(strcat(filename,".hex"),"w");
	if (f_hex==(FILE *) NULL)
		{
		printf("Could not open file.hex for write.");
		return;
		}
	for (x=0;x<32767-16;x+=16)
	{
		flag=0;
		for (y=0;y<=15;y++)
			if (mem[x+y]!=0) flag=1;
		if (flag==1)
		{
			hexsflag=1;
			hexs(x);
			hexsflag=0;
			strcpy(longstr,hexstr);
			strcat(longstr,":    ");
			for (y=0;y<=15;y++)
			{
				hexs(mem[x+y]);
				strcat(longstr,hexstr);
				strcat(longstr," ");
				if (y==7) strcat(longstr," ");
			}
			fprintf(f_hex,"%s\n",longstr);
		}
	}
	fclose(f_hex);
	return;
}	

void codeit(t)
char t[80];
{
	char sht[3];
	char tdup[80];
	char buf[80];
	char tdup2[80];
	int ad,x,y;
	strcpy(tdup,t);	
	if (pass==1) return;
	hexsflag=1;
	hexs(addr);
	hexsflag=0;
	sht[2]='\0';
	strcpy(buf,buffer);
	if (strlen(buffer)>50) strnullcpy(buf,buffer,50);
	strcpy(tdup2,tdup);
	if (strlen(tdup)>6) strnullcpy(tdup2,tdup,6);
	fprintf(f_lst,"%5d %4s  %6s   %s\n",line,hexstr,tdup2,buf);
	
	if (tdup[0]!=' ')
	{
		ad=addr;
		for (x=0;x<strlen(tdup);x+=2)
		{
			y=tdup[x]-48;
			if (y>9) y-=7;
			value=y*16;
			y=tdup[x+1]-48;
			if (y>9) y-=7;
			value+=y;	
			mem[ad++]=value;
		}
	}
	return;
}

int tag_defined(t)
char t[80];
{
	LINK	list;
	list=tag_list;
	while (list!=(LINK) NULL)
	{
		if (strcmp(t,list->tag)==0)
			return(1);
		list=list->next;
	}
	return(0);
} 
	
void add_tag(val) 
int val;
{
	LINK	list;
	list=tag_list;
	if (list!=(LINK) NULL)
		while (list->next!=(LINK) NULL)
			list=list->next;
	if (list==(LINK) NULL)
	{
		tag_list=(LINK) malloc(sizeof(ELEM));
		strcpy(tag_list->tag,name);
		tag_list->value=val;
		tag_list->next=(LINK) NULL;
	}
	else
	{
		list->next=(LINK) malloc(sizeof(ELEM));
		strcpy(list->next->tag,name);
		list->next->value=val;
		list->next->next=(LINK) NULL;
	}
	return;
} 

int validtag(t)
char t[80];
{
	int x;
	for (x=0;x<strlen(t);x++)
	{
		if ((
		((s[x]>='A')&&(s[x]<='Z'))||
		((s[x]>='0')&&(s[x]<='9'))||
		(s[x]=='_')
		)==0)
			return(0);
	}
	return(1);
}
		
void gettag(x)
int x;
{
	strnullcpy(name,s,x);
	if (validtag(name)==0)
		cleanexit("Tag contains extranneous characters.");
	if (pass==1)
	{
		if (tag_defined(name)) cleanexit("Tag already defined.");
		add_tag(addr);
	}
	hack(x+1);
	return;
}

int testbase(b,c)
int b;
char c;
{
	int n;
	n=((int) c)-48;
 if (n<0) return(-1);
	if ((n>9)&&(n<17)) return(-1);
	if (n>9) n-=7;
	if (n>(b-1)) return(-1);
	return(n);
}

void convert(base)
int base;
{
	int x;
	value=0;
	while ((x=testbase(base,s[0]))>=0)
	{
		hack(1);
		value*=base;
		value+=x;
	}
	return;
}
 
int lookup()
{
	LINK	list;
	list=tag_list;
	while (list!=(LINK) NULL)
	{
		if (strcmp(list->tag,name)==0) return(list->value);
		list=list->next;
	}
	cleanexit("Lookup on identifier failed.");
}

int regist(t)
char t[80];
{
	if (strcmp(t,"AB")==0) return(18);
	if (strcmp(t,"A")==0) return(1);
	if (strcmp(t,"DPTR")==0) return(4);
	if (t[0]=='R')
		if (((t[1]>='0')&&(t[1]<='7'))&&(t[2]=='\0'))
			return( ((int) t[1]) -38);
	if (strcmp(t,"C")==0) return(3);
	if (strcmp(t,"@DPTR")==0) return(5);
	if (strcmp(t,"@R0")==0) return(8);
	if (strcmp(t,"@R1")==0) return(9);
	return(0);
}

int getexp()
{
	int flag,x;
	value=0;
	flag=0;
	if (s[0]=='#')
	{
		hack(1);
		flag=1;
	}
	if (strncmp(s,"H'",2)==0)
	{
		hack(2);
		convert(16,s);
		return(7-flag);
	}
	if (strncmp(s,"B'",2)==0)
	{
		hack(2);
		convert(2,s);
		return(7-flag);
	}
	x=0;
	if (testbase(10,s[0])>=0)
	{
		while(testbase(16,s[x])>=0) x++;
		if (s[x]=='H') {convert(16,s);hack(1);return(7-flag);}
		if (s[x-1]=='B') {convert(2,s);hack(1); return(7-flag);}
		convert(10,s); return(7-flag);
	}
	if (s[0]=='\'')
	{
		hack(1);
		if (s[1]!='\'') cleanexit("Need another single quote.");
		value=(int) s[0];
		hack(2);
		if (flag==0)
		{
			warn("Character constants not advisable here.");
			return(7);
		}
		return(6);
	}
	x=0;
	while (
	(s[0]!=',')&&
	(s[0]!='\0')&&
	(s[0]!='+')&&
	(s[0]!='*')&&
	(s[0]!='-')&&
	(s[0]!=';')&&
	(s[0]!=' ')
	)
	{
		name[x++]=s[0];
		hack(1);
	}
	name[x]='\0';
	while (s[0]==' ') hack(1);
	x=regist(name);
	if (x>0) return(x);
	if (tag_defined(name)==0)
	{
		if (pass==1) {value=0;return(7-flag);}
		cleanexit("Need to define this expression.");
	}
	value=lookup();
	return(7-flag);
}
		
int getbyte()
{
	int v,x,firstx;
	char c;
	x=getexp();	
	v=value;
	firstx=x;
	while ((s[0]=='+')||(s[0]=='-')||(s[0]=='*'))
	{
		c=s[0];
		hack(1);
		x=getexp();
		if (x!=firstx) cleanexit("Expression types must match.");
		switch(c) {
			case '+':
				v+=value;
				break;
			case '-':
				v-=value;
				break;
			case '*':
				v*=value;
				break;
			default:
				break;
			}
	}
	realvalue=v;
	value=v;
	if (value<-65536) cleanexit("Value out of range.");
	if (value<-128) value+=65536;
	if (value<0) value+=256;
	if (value>65535) cleanexit("Value out of range.");
	return(x);
}

void equate()
{
	char left[80];
	int x;
	hack(5);
	x=0;
	while ((s[x]!=',')&&(s[x]!='\0')) x++;
	if (s[x]!=',') cleanexit("Equate needs a comma.");
	strnullcpy(left,s,x);
	if (regist(left)>0) cleanexit("Cannot use registers in equate.");
	hack(x+1);
	codeit("  ->");
	if (pass==2)
	{
		x=getbyte();
		return;
	}
	if (tag_defined(left)==1)
		cleanexit("Identifier already defined.");
	if (getbyte()!=7) cleanexit("Value must be a byte/word.");
	strcpy(name,left);
	add_tag(value);
	return;
}

void origin()
{
	hack(5);
	if (getbyte()!=7) cleanexit("Must be byte/word.");
	if (pass==2) codeit("  ->");
	addr=value;
	return;
}

void defbyte()
{
	hack(4);
	if (getbyte()!=7) cleanexit("Must be byte.");
	if (value>255) cleanexit("Byte value out of range.");
	if (pass==2)
	{
		hexs(value);
		codeit(hexstr);
	}
	addr+=1;
	return;
}

void defword()
{
	hack(4);
	if (getbyte()!=7) cleanexit("Must be word.");
	if (pass==2)
	{
		hexsflag=1;
		hexs(value);
		hexsflag=0;
		codeit(hexstr);
	}
	addr+=2;
	return;
}

void defmsg()
{
	char t[80];
	int x;
	hack(4);
	if (s[0]!='\'')
		cleanexit("Must start with single quote.");
	hack(1);
	t[0]='\0';
	for (x=0;x<=pos;x++)
	{
		if (s[x]=='\'')
		{
			if (pass==2) codeit(t);
			addr+=x;
			hack(x+1);
			return;
		}
		if (pass==2)
		{
			hexs(s[x]);
			strcat(t,hexstr);
		}
	}
	cleanexit("Must end with single quote.");
}

void reserve()
{
	hack(4);
	if (getbyte()!=7) cleanexit("Must be byte/word.");
	if (pass==2) codeit("  ->");
	addr+=value;
	return;
}

void endassm()
{
	hack(4);
	return;
}

void getdirec()
{
	if (strncmp(s,".EQU",4)==0) {equate();return;}
	if (strncmp(s,".ORG",4)==0) {origin();return;}
	if (strncmp(s,".DB",3)==0) {defbyte();return;}
	if (strncmp(s,".DW",3)==0) {defword();return;}
	if (strncmp(s,".DM",3)==0) {defmsg();return;}
	if (strncmp(s,".RS",3)==0) {reserve();return;}
	if (strncmp(s,".END",3)==0) {endassm();return;}
	cleanexit("Compiler directive not understood.");
}

void get2()
{
	mi=1;
	lop=getbyte();
	lval=value;
	if ((lop==6)||(lop==7)) mi++;
	if (lval>255) cleanexit("Left operator value > 255.");
	if (s[0]!=',')
		cleanexit("This statement needs two operands.");
	hack(1);
	rop=getbyte();
	rval=value;
	if ((rop==6)||(rop==7)) mi++;
	if (rval>255) cleanexit("Right operator value > 255.");
	return;
}

void get1()
{
	mi=1;
	lop=getbyte();
	lval=value;
	if ((lop==6)||(lop==7)) mi++;
	if (lval>255) cleanexit("Operator value > 255.");
	return;
}

void addr11()
{
	lop=getbyte();
	if (lop!=7) cleanexit("Operand must be an address.");
	if (pass==1) {value=0;return;}
	if ((value&63488)!=(addr&63488))
		cleanexit("11 bit address out of range.");
	value&=2047;
	return;
}

void addr16()
{
	lop=getbyte();
	if (lop!=7) cleanexit("Operand must be an address.");
	return;
}

void data16()
{
	lop=getbyte();
	if (lop!=6) cleanexit("Operand must be data.");
	return;
}

int getrel()
{
	int x,r;
	x=getbyte();
	if (x!=7) cleanexit("Operand must be an address.");
	if (pass==1) {return(0);} 
	r=realvalue-(addr+mi);
	if (r<-128) cleanexit("Relative offset < -128.");
	if (r>127) cleanexit("Relative offset > 127.");
	if (r<0) r+=256;
	return(r);
}


void ljmp()
{
	hack(5);
	addr16();
	hexs(02*65536+value);
	codeit(hexstr);
	addr+=3;
}

void form0(n)
int n;
{
	mi=2;
	hexs(n*256+getrel());
	codeit(hexstr);
	addr+=mi;
}

void sjmp()
{
	hack(5);
	form0(128);
}

jc()
{
	hack(3);
	form0(64);
}

jnc()
{
	hack(4);
	form0(80);
}

void form1(n)
int n;
{
	get1();
	mi++;
	if (lop!=7) cleanexit("Left operand must be bit address.");
	if (s[0]!=',') cleanexit("This command needs two operands.");
	hack(1);
	hexs(n*65536+lval*256+getrel());
	codeit(hexstr);
	addr+=mi;
}

void jb()
{
	hack(3);
	form1(32);
}

void jnb()
{
	hack(4);
	form1(48);
}

void jbc()
{
	hack(4);
	form1(16);
}
	
void form2(n)
int n;
{
	int x,y;
	addr11();
	x=(value/256)<<5;
	x+=n;
	y=(value%256);
	hexs(x*256+y);
	codeit(hexstr);
	addr+=2;
}

void ajmp()
{
	hack(5);
	form2(1);
	}

void acall()
{
	hack(6);
	form2(17);
}

void lcall()
{
	hack(6);
	addr16();
	hexs(18*65536+value);
	codeit(hexstr);
	addr+=3;
}

void jz()
{
	hack(3);
	form0(96);
}

void jnz()
{
	hack(4);
	form0(112);
}

void djnz()
{
	hack(5);
	get1();
	if (s[0]!=',') cleanexit("This statement needs two operands.");
	hack(1);
	mi++;
	if (lop==7)
	{
		hexs(213*65536+lval*256+getrel());
		codeit(hexstr);
		addr+=mi;
		return;
	}
	if ((lop>=10)&&(lop<=17))
	{
		hexs((216-10+lop)*256+getrel());
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Left operand must be a direct addr or Rn.");
}

void cjne()
{
	hack(5);
	get2();
	if (s[0]!=',') cleanexit("This statement needs 3 operands.");
	hack(1);
	mi++;
	if (lop==1)
	{
		if (rop==6)
		{
			hexs(180*65536+rval*256+getrel());
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==7)
		{
			hexs(181*65536+rval*256+getrel());
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Middle operand must be # or $.");
	}
	if ((lop>=8)&&(lop<=17))
	{
		if (rop!=6) cleanexit("Middle operand must be #.");
		hexs((182-8+lop)*65536+rval*256+getrel());
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Left operand must be A,@Ri, or Rn.");
}

void movdptr()
{
	hack(8);
	if (s[0]!=',') cleanexit("Comma needed.");
	hack(1);
	data16();
	hexs(144*65536+value);
	codeit(hexstr);
	addr+=3;
	return;
}

void form4(n)
int n;
{
	get2();
	if (lop!=1) cleanexit("Left operand must be A.");
	if ((rop>=6)&&(rop<=17))
	{
		hexs(n-6+rop);
		if ((rop==6)||(rop==7))
		{
			hexs((n-6+rop)*256+rval);
		}
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Right operand must be #,$,@Ri, or Rn.");
}

void addc()
{
	hack(5);
	form4(52);
}

void add()
{
	hack(4);
	form4(36);
}

void subb()
{
	hack(5);
	form4(148);
}

void inc()
{
	hack(4);
	get1();
	if (lop==1) lop=6;
	if ((lop>=6)&&(lop<=17))
	{
		hexs(4-6+lop);
		if (lop==7)
			hexs((4-6+lop)*256+lval);
		codeit(hexstr);
		addr+=mi;
		return;
	}
	if (lop==4)
	{
		hexs(163);
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Operand must be A,$,@Ri, Rn, or DPTR.");
}

void dec()
{
	hack(4);
	get1();
	if (lop==1) lop=6;
	if ((lop>=6)&&(lop<=17))
	{
		hexs(20-6+lop);
		if (lop==7)
			hexs((20-6+lop)*256+lval);
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Operand must be A,$,@Ri, or Rn.");
}

void mul()
{
	hack(4);
	get1();
	if (lop!=18) cleanexit("Operand must be AB.");
	hexs(164);
	codeit(hexstr);
	addr++;
}

void div()
{
	hack(4);
	get1();
	if (lop!=18) cleanexit("Operand must be AB.");
	hexs(132);
	codeit(hexstr);
	addr++;
}

void da()
{
	hack(3);
	get1();
	if (lop!=1) cleanexit("Operand must be A.");
	hexs(212);
	codeit(hexstr);
	addr++;
}

void form5(n,m,o,p)
int n;
int m;
int o;
int p;
{
	get2();
	if (lop==1)
	{
		if ((rop>=6)&&(rop<=17))
		{
			hexs(n-8+rop);
			if ((rop==6)||(rop==7))
				hexs((m-6+rop)*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right OP must be #,$,@Ri, or Rn.");
	}
	if (lop==7)
	{
		if (rop==1)
		{
			hexs(o*256+lval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==6)
		{
			hexs((o+1)*65536+lval*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be A or #.");
	}
	if (lop==3)
	{
		if (rop==7)
		{
			hexs(p*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be bit address.");
	}
	cleanexit("Left operand must be A, C, or $.");
}

void orl()
{
	hack(4);
	form5(70,68,66,114);
}

void anl()
{
	hack(4);
	form5(86,84,82,130);
}

void xrl()
{
	hack(4);
	get2();
	if (lop==1)
	{
		if ((rop>=6)&&(rop<=17))
		{
			hexs(100-6+rop);
			if ((rop==6)||(rop==7))
				hexs((100-6+rop)*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right OP must be #,$,@Ri, or Rn.");
	}
	if (lop==7)
	{
		if (rop==1)
		{
			hexs(98*256+lval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==6)
		{
			hexs(99*65536+lval*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be A or #.");
	}
	cleanexit("Left operand must be A or $.");
}

void form6(n,m,o)
int m,n,o;
{
	get1();
	if (lop==1)
	{
		hexs(n);
		codeit(hexstr);
		addr++;
		return;
	}
	if (lop==3)
	{
		hexs(m);
		codeit(hexstr);
		addr++;
		return;
	}
	if (lop==7)
	{
		hexs(o*256+lval);
		codeit(hexstr);
		addr+=2;
		return;
	}
	cleanexit("Operand must be A, C, or $.");
}

void clr()
{
	hack(4);
	form6(228,195,194);
}

void cpl()
{
	hack(4);
	form6(244,179,178);
}

void setb()
{
	hack(5);
	get1();
	if (lop==3)
	{
		hexs(211);
		codeit(hexstr);
		addr++;
		return;
	}
	if (lop==7)
	{
		hexs(210*256+lval);
		codeit(hexstr);
		addr+=2;
		return;
	}
	cleanexit("Operand must be C or $.");
}

void form7(n)
int n;
{
	get1();
	if (lop!=1) cleanexit("Operand must be A.");
	hexs(n);
	codeit(hexstr);
	addr++;
}

void rl()
{
	hack(3);
	form7(35);
}

void rlc()
{
	hack(4);
	form7(51);
}

void rr()
{
	hack(3);
	form7(3);
}

void rrc()
{
	hack(4);
	form7(19);
}

void swap()
{
	hack(5);
	form7(196);
}

void mov()
{
	hack(4);
	get2();
	if (lop==1)
	{
		if ((rop>=7)&&(rop<=17))
		{
			hexs(229-7+rop);
			if (rop==7)
				hexs(229*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==6)
		{
			hexs(116*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be #,$,@Ri, or Rn.");
	}
	if ((lop>=8)&&(lop<=17))
	{
		if (rop==1)
		{
			hexs(245-8+lop);
			if (lop==7)
				hexs((245-8+lop)*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==7)
		{
			hexs((166-8+lop)*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==6)
		{
			hexs((118-8+lop)*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be A,#, or $.");
	}
	if (lop==7)
	{
		if ((rop>=7)&&(rop<=17))
		{
			hexs((133-7+rop)*256+lval);
			if (rop==7)
				hexs(133*65536+lval*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==6)
		{
			hexs(117*65536+lval*256+rval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==3)
		{
			hexs(146*256+lval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		if (rop==1)
		{
			hexs(245*256+lval);
			codeit(hexstr);
			addr+=mi;
			return;
		}
		cleanexit("Right operand must be #,$, @Ri, or Rn.");
	}
	if (lop==3)
	{
		if (rop!=7) cleanexit("Right operand must be bit addr.");
		hexs(162*256+rval);
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Left operand must be A,$, or C.");
}

void movx()
{
	hack(5);
	get2();
	if (lop==1)
	{
		if (rop==5)
		{
			hexs(224);
			codeit(hexstr);
			addr++;
			return;
		}
		if (rop==8)
		{
			hexs(226);
			codeit(hexstr);
			addr++;
			return;
		}
		if (rop==9)
		{
			hexs(227);
			codeit(hexstr);
			addr++;
			return;
		}
		cleanexit("Right operand must be @Ri, or @DPTR.");
	}
	if (lop==5)
	{
		if (rop!=1) cleanexit("Right OP must be A.");
		hexs(240);
		codeit(hexstr);
		addr++;
		return;
	}
	if (lop==8)
	{
		if (rop!=1) cleanexit("Right OP must be A.");
		hexs(242);
		codeit(hexstr);
		addr++;
		return;
	}
	if (lop==9)
	{
		if (rop!=1) cleanexit("Right OP must be A.");
		hexs(243);
		codeit(hexstr);
		addr++;
		return;
	}
	cleanexit("Left operand must be A,@Ri, or @DPTR.");
}

void pop()
{
	hack(4);
	get1();
	if (lop!=7) cleanexit("Operand must be direct byte.");
	hexs(208*256+lval);
	codeit(hexstr);
	addr+=mi;
}

void push()
{
	hack(5);
	get1();
	if (lop!=7) cleanexit("Operand must be direct byte.");
	hexs(192*256+lval);
	codeit(hexstr);
	addr+=mi;
}

void form8(n)
int n;
{
	hexs(n);
	codeit(hexstr);
	addr++;
	return;
}

void ret()
{
	hack(3);
	form8(34);
}

void reti()
{
	hack(4);
	form8(50);
}

void nop()
{
	hack(3);
	form8(0);
}

void xch()
{
	hack(4);
	get2();
	if (lop!=1) cleanexit("Left operand must be A.");
	if ((rop>=7)&&(rop<=17))
	{
		hexs(197-7+rop);
		if (rop==7) hexs((197-7+rop)*256+rval);
		codeit(hexstr);
		addr+=mi;
		return;
	}
	cleanexit("Right operand must be $,@Ri, or Rn.");
}

void xchd()
{
	hack(5);
	get2();
	if (lop!=1) cleanexit("Left operand must be A.");
	if ((rop>=8)&&(rop<=17))
	{
		hexs(214-8+rop);
		codeit(hexstr);
		addr++;
		return;
	}
	cleanexit("Right operand must be @Ri.");
}

void movcadptr()
{
	hack(14);
	hexs(147);
	codeit(hexstr);
	addr++;
}

void movcapc()
{
	hack(12);
	hexs(131);
	codeit(hexstr);
	addr++;
}

void jmpadptr()
{
	hack(11);
	hexs(115);
	codeit(hexstr);
	addr++;
}

void opcode()
{
	if (strncmp(s,"ADDC ",5)==0) {addc();return;}
	if (strncmp(s,"ADD ",4)==0) {add();return;}
	if (strncmp(s,"SUBB ",5)==0) {subb();return;}
	if (strncmp(s,"INC ",4)==0) {inc();return;}
	if (strncmp(s,"DEC ",4)==0) {dec();return;}
	if (strncmp(s,"MUL ",4)==0) {mul();return;}
	if (strncmp(s,"DIV ",4)==0) {div();return;}
	if (strncmp(s,"DA ",3)==0) {da();return;}
	if (strncmp(s,"ANL ",4)==0) {anl();return;}
	if (strncmp(s,"ORL ",4)==0) {orl();return;}
	if (strncmp(s,"XRL ",4)==0) {xrl();return;}
	if (strncmp(s,"CPL ",4)==0) {cpl();return;}
	if (strncmp(s,"RLC ",4)==0) {rlc();return;}
	if (strncmp(s,"RR ",3)==0) {rr();return;}
	if (strncmp(s,"RRC ",4)==0) {rrc();return;}
	if (strncmp(s,"RL ",3)==0) {rl();return;}
	if (strncmp(s,"SWAP ",5)==0) {swap();return;}
	if (strncmp(s,"MOVX ",5)==0) {movx();return;}
	if (strncmp(s,"MOV DPTR",8)==0) {movdptr();return;}
	if (strncmp(s,"MOVC A,@A+DPTR",14)==0) {movcadptr();return;}
	if (strncmp(s,"MOVC A,@A+PC",12)==0) {movcapc();return;}
	if (strncmp(s,"JMP @A+DPTR",11)==0) {jmpadptr();return;}
	if (strncmp(s,"MOV ",4)==0) {mov();return;}
	if (strncmp(s,"PUSH ",5)==0) {push();return;}
	if (strncmp(s,"POP ",4)==0) {pop();return;}
	if (strncmp(s,"XCHD ",5)==0) {xchd();return;}
	if (strncmp(s,"XCH ",4)==0) {xch();return;}
	if (strncmp(s,"CLR ",4)==0) {clr();return;}
	if (strncmp(s,"SETB ",5)==0) {setb();return;}
	if (strncmp(s,"JC ",3)==0) {jc();return;}
	if (strncmp(s,"JNC ",4)==0) {jnc();return;}
	if (strncmp(s,"JNB ",4)==0) {jnb();return;}
	if (strncmp(s,"JBC ",4)==0) {jbc();return;}
	if (strncmp(s,"JB ",3)==0) {jb();return;}
	if (strncmp(s,"ACALL ",6)==0) {acall();return;}
	if (strncmp(s,"LCALL ",6)==0) {lcall();return;}
	if (strncmp(s,"RETI",4)==0) {reti();return;}
	if (strncmp(s,"RET",3)==0) {ret();return;}
	if (strncmp(s,"SJMP ",5)==0) {sjmp();return;}
	if (strncmp(s,"LJMP ",5)==0) {ljmp();return;}
	if (strncmp(s,"AJMP ",5)==0) {ajmp();return;}
	if (strncmp(s,"JZ ",3)==0) {jz();return;}
	if (strncmp(s,"JNZ ",4)==0) {jnz();return;}
	if (strncmp(s,"CJNE ",5)==0) {cjne();return;}
	if (strncmp(s,"DJNZ ",5)==0) {djnz();return;}
	if (strncmp(s,"NOP",3)==0) {nop();return;}
	if ((s[0]>32)&&(s[0]<127)) 
		warn("Syntax Error.");
	return;
}

void assemble()
{
	int x,y;
	while (s[0]==' ') hack(1);
	if (s[0]==';') {codeit("  **"); return;}
	y=(-1); x=0;
	do
	{
		if (s[x]==';')		
			y=x;
		x++;
	} while ((x<=pos)&&(y<0));
	if (y>=0)
	{
		s[y]='\0';
		pos=y;
	}

	while (s[0]==':')
	{
	warn (": at beginning of line.");
	hack(1);
	}
	
	for (x=0;x<=pos;x++)
		if (s[x]==':')
		{
			if (pass==1) gettag(x);
			else hack(x+1);
			while (s[0]==' ') hack(1);
			if (s[0]=='\0') codeit(" --]");
		}
	while (s[0]==' ') hack(1);	
	if (s[0]=='.') {getdirec();return;}
	opcode();
	return;
}

int getline()
{
	int x;
	x=0;
	while ((c=fgetc(f))<32)
	{
		if (c=='\n')
			 {strcpy(buffer,"    ");line++;codeit("     ");}
		if (c==EOF) return(-1);
	}
	buffer[x++]=c;
	while ((c=fgetc(f))!='\n')
		buffer[x++]=c;
	buffer[x]='\0';
	return(x);
}

void main(argc,argv)
int argc;
char *argv[];
{
	int n,x,y,last,white;
	char filename[80];
	LINK tl;
	tag_list=(LINK) NULL;
	printf("8051 assembler by Eric Rudolph, 1991. Version 1.\n");
	strcpy(basename,argv[1]);
	strcpy(filename,basename);
	f=fopen("a51.equ","r");
	if (f==(FILE *) NULL)
		printf("Could not find asm.equ file.\n");
	else
		do
		{
			fscanf(f,"%s",name);
			fscanf(f,"%d",&value);
			if (value>0) add_tag(value);
		} while (value>0);
	for (x=0;x<32767;x++)
		mem[x]=0;
	
	f=fopen(filename,"r");
	hexsflag=0;
	if (f!=(FILE *) NULL)
	{
		printf("PASS1\n");
		addr=0;pass=1;line=0;
		do
		{
			n=getline();
			if (n>0)
			{
				line++;
				y=0;
				last=1;
				for (x=0;x<=n;x++)
				{
					white=0;
if ((buffer[x]==' ')||(buffer[x]=='\t'))
	white=1;
if ((white==1)&&(last==0))
	s[y++]=' ';
if (white==0)
{
	s[y]=buffer[x];
	if ((buffer[x]>='a')&&(buffer[x]<='z')) s[y]-=32;
	y++;
}
					last=white;
				}
				pos=strlen(s);
				if (s[pos-1]==' ') {s[pos-1]='\0';pos--;}
				assemble();
			}
		} while (n>=1);
		fclose(f);
		printf("PASS2\n");
		f=fopen(filename,"r");
		strcat(filename,".lst");
		f_lst=fopen(filename,"w");
		if (f_lst==(FILE *) NULL) cleanexit("Can't open .lst for write.");
		addr=0;pass=2;line=0;
		do
		{
			n=getline();
			if (n>0)
				{
				line++;
				y=0;
				last=1;
				for (x=0;x<=n;x++)
				{
					white=0;
if ((buffer[x]==' ')||(buffer[x]=='\t'))
	white=1;
if ((white==1)&&(last==0))
	s[y++]=' ';
if (white==0)
{
	s[y]=buffer[x];
	if ((buffer[x]>='a')&&(buffer[x]<='z')) s[y]-=32;
	y++;
}
					last=white;
				}
				pos=strlen(s);
				if (s[pos-1]==' ') {s[pos-1]='\0';pos--;}
				assemble();
			}
		} while (n>=1);
		fprintf(f_lst,"=============================\n");
		tl=tag_list;
		x=0;
		hexsflag=0;
		while (tl!=(LINK) NULL)
		{
			if (x==0) fprintf(f_lst,"\n");
			else fprintf(f_lst,"\t");
			hexs(tl->value);
			fprintf(f_lst,"%s\t%s",tl->tag,hexstr);
			tl=tl->next;
		}
		fprintf(f_lst,"\n\n");
		fclose(f_lst);
		showcode();
		printf("END OF ASSEMBLY.\n");
	}
	else 
		printf("No such file.\n");
	
}

