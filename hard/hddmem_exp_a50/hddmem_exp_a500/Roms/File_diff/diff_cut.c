// difference cutter

// diff_cut file1 file2 file3
// file1 - original file
// file2 - change original
// file3 - file for save differences

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

struct stat *st;

FILE *origin_f;
FILE *change_f;
FILE *result_f;

unsigned char *buf1=" ",*buf2=" ",*buf3=" ";

long int fs1,fs2,x1,cc,fa;

int rc,fh;

// *****************************************************************


void main(int argc, char **argv)
 {

 if (argc<4)
   {
   printf("diff_cut file1 file2 file3\n");
   printf("  file1 - original file\n");
   printf("  file2 - change original\n");
   printf("  file3 - file for save changes\n");
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

 change_f=fopen(argv[2],"rb");
 if (!change_f)
   {
   printf("error: file %s don't open\n",argv[2]);
   exit(0);
   }

 fh=fileno(change_f);
 rc=fstat(fh,st);
 if (rc==-1)
   {
   printf("error in file %s\n",argv[2]);
   exit(0);
   }
 fs2=st->st_size;

 if (fs1!=fs2)
   {
   printf("error: lenght of file %s not equalent lenght of file %s\n",argv[1],argv[2]);
   exit(0);
   }

 result_f=fopen(argv[3],"wb");
 if (!result_f)
   {
   printf("error: file %s don't open for write\n",argv[3]);
   exit(0);
   }

 cc=0;

 for (fa=0;fa<fs1;fa++)
   {
   x1=fread(buf1,1,1,origin_f);
   if (x1!=1)
     {
     printf("error: file %s don't read\n",argv[1]);
     exit(0);
     }
   x1=fread(buf2,1,1,change_f);
   if (x1!=1)
     {
     printf("error: file %s don't read\n",argv[2]);
     exit(0);
     }
   if (*buf1!=*buf2)
     {
     *buf3=(fa>>24)&0xff;
     x1=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     *buf3=(fa>>16)&0xff;
     x1=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     *buf3=(fa>>8)&0xff;
     x1=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     *buf3=fa&0xff;
     x1=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     *buf3=*buf2;
     x1=fwrite(buf3,1,1,result_f);
     if (x1!=1)
       {
       printf("error: file %s don't write\n",argv[3]);
       exit(0);
       }
     }
   cc++;
   }

 if (cc==0) printf("files is full equalent\n");
 fclose(origin_f);
 fclose(change_f);
 fclose(result_f);
 free(st);
 }
