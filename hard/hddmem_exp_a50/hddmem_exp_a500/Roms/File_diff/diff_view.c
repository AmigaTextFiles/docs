// difference viewer

// diff_view file1
// file1 - differences file

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

struct stat *st;

FILE *result_f;

unsigned char *buf3=" ";

long int fs1,x1,fa;
unsigned long int fs2;

int rc,fh,fs3;

// *****************************************************************


void main(int argc, char **argv)
 {

 if (argc<2)
   {
   printf("diff_view file1\n");
   printf("  file1 - differences file\n");
   exit(0);
   }

 st=calloc(sizeof(struct stat),1);
 if (!st) exit(0);

 result_f=fopen(argv[1],"rb");
 if (!result_f)
   {
   printf("error: file %s don't open\n",argv[1]);
   exit(0);
   }

 fh=fileno(result_f);
 rc=fstat(fh,st);
 if (rc==-1)
   {
   printf("error in file %s\n",argv[1]);
   exit(0);
   }
 fs1=st->st_size;

 if (fs1==0)
   {
   printf ("no differences found\n");
   exit(0);
   }
 if (fs1%5!=0)
   {
   printf ("file %s - not differences file\n",argv[1]);
   exit(0);
   }

 printf("%ld differences:\n",fs1/5);

 for (fa=0;fa<fs1/5;fa++)
   {
   fs2=0L;

   x1=fread(buf3,1,1,result_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs2=fs2|(unsigned long int)((unsigned long int)*buf3<<24);

   x1=fread(buf3,1,1,result_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs2=fs2|(unsigned long int)((unsigned long int)*buf3<<16);

   x1=fread(buf3,1,1,result_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs2=fs2|(unsigned long int)((unsigned long int)*buf3<<8);

   x1=fread(buf3,1,1,result_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs2=fs2|((unsigned long int)*buf3);

   x1=fread(buf3,1,1,result_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs3=(unsigned long int)*buf3;
   printf("%8.8lx %2.2lx\n",fs2,fs3);
   }

 fclose(result_f);
 free(st);
 }
