#include <stdio.h>
#include <string.h>
#include <stdlib.h>

FILE *infile,*outfile_even,*outfile_odd;
long int i,j,step,count,istep,istep2;
unsigned char *ch,*ch1,*ch2;
unsigned char che;

void main(int argc, char **argv)
 {
 if (argc<4)
   {
   printf ("syntax: in_rom even_out_rom odd_out_rom\n");
   exit(0);
   }
 if (!( ch=calloc (0x80000L,1) ))
   {
   printf ("low memory\n");
   exit(0);
   }
 if (!( infile=fopen (argv[1],"rb") ))
   {
   printf ("input file not open\n");
   free(ch);
   exit(0);
   }
 if (!( outfile_even=fopen (argv[2],"wb") ))
   {
   fclose(infile);
   printf ("even output file not open\n");
   free(ch);
   exit(0);
   }
 if (!( outfile_odd=fopen (argv[3],"wb") ))
   {
   fclose(infile);
   fclose(outfile_even);
   printf ("odd output file not open\n");
   free(ch);
   exit(0);
   }

 fread(ch,1,0x80000L,infile);

 step=4L;
 count=0x80000L/step;

 while (count>=1L)
   {
   istep=step/2L;
   istep2=step/4L;
//   printf("count-%d step-%d istep-%d istep2-%d\n",count,step,istep,istep2);

   for (i=0;i<count;i++)
     {
     ch1=ch+(i*step)+istep2;
     ch2=ch+(i*step)+istep;
     for (j=0;j<istep2;j++)
       {
       che=*ch1;
       *ch1=*ch2;
       *ch2=che;
       ch1++;
       ch2++;
       }
     }
   step=step*2L;
   count=count/2L;
   }

 ch1=ch;
 ch2=ch+0x40000;
 fwrite(ch1,1,0x40000,outfile_even);
 fwrite(ch2,1,0x40000,outfile_odd);

 fclose(infile);
 fclose(outfile_even);
 fclose(outfile_odd);
 free(ch);
 }
