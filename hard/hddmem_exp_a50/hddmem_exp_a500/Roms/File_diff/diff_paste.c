// difference paste

// diff_paste file1 file2 file3
// file1 - original file
// file2 - change original
// file3 - file for save differences

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

struct stat *st;

FILE *origin_f;
FILE *dif_f;
FILE *result_f;

unsigned char *buf3=" ";

long int fs1,fs2,x1,fa;
unsigned long int fs3;

int rc,fh;

// *****************************************************************


void main(int argc, char **argv)
 {

 if (argc<4)
   {
   printf("diff_paste file1 file2 file3\n");
   printf("  file1 - original file for read\n");
   printf("  file2 - differences file for read\n");
   printf("  file3 - change version of original file for write\n");
   exit(0);
   }

 st=calloc(sizeof(struct stat),1);
 if (!st) exit(0);

 origin_f=fopen(argv[1],"rb");
 if (!origin_f)
   {
   printf("error: file %s don't open\n",argv[1]);
   exit(0);
   }

 fh=fileno(origin_f);
 rc=fstat(fh,st);
 if (rc==-1)
   {
   printf("error in file %s\n",argv[1]);
   exit(0);
   }
 fs1=st->st_size;
 if (fs1==0)
   {
   printf("file %s is empty\n",argv[1]);
   exit(0);
   }

 dif_f=fopen(argv[2],"rb");
 if (!dif_f)
   {
   printf("error: file %s don't open\n",argv[2]);
   exit(0);
   }

 fh=fileno(dif_f);
 rc=fstat(fh,st);
 if (rc==-1)
   {
   printf("error in file %s\n",argv[2]);
   exit(0);
   }
 fs2=st->st_size;
 if (fs2==0)
   {
   printf("file %s is empty\n",argv[2]);
   exit(0);
   }
 if (fs2%5!=0)
   {
   printf ("file %s - not differences file\n",argv[2]);
   exit(0);
   }

 result_f=fopen(argv[3],"wb");
 if (!result_f)
   {
   printf("error: file %s don't open for write\n",argv[3]);
   exit(0);
   }

 for (fa=0;fa<fs1;fa++)     // copy file
   {
   fread(buf3,1,1,origin_f);
   fwrite(buf3,1,1,result_f);
   }

 for (fa=0;fa<fs2/5;fa++)
   {
   fs3=0L;

   x1=fread(buf3,1,1,dif_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs3=fs3|(unsigned long int)((unsigned long int)*buf3<<24);

   x1=fread(buf3,1,1,dif_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs3=fs3|(unsigned long int)((unsigned long int)*buf3<<16);

   x1=fread(buf3,1,1,dif_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs3=fs3|(unsigned long int)((unsigned long int)*buf3<<8);

   x1=fread(buf3,1,1,dif_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }
   fs3=fs3|((unsigned long int)*buf3);

   x1=fread(buf3,1,1,dif_f);
   if (x1!=1)
     {
     printf("error: file %s don't write\n",argv[3]);
     exit(0);
     }

   rc=fseek(result_f,fs3,SEEK_SET);
   if (rc==-1) printf("error byte position %8.8lx in differences file\n",fs3);
   else
     {
     rc=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     }
   }

 fclose(origin_f);
 fclose(dif_f);
 fclose(result_f);
 free(st);
 }
