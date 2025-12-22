/*******************************************
 *  Chop                                   *
 *                                         *
 *  by J S Plegge                          *
 *                                         *
 *  Truncate files to specified length     *
 *                                         *
 *  USAGE:  Chop <input> <output> <size>   *
 *                                         *
 *******************************************/

#include <stdio.h>
#include <ctype.h>

usage()
{
puts("Usage:  CHOP <input> <output> <size>");
}

main(argc, argv)

int argc;
char *argv[];

{
int i;
int c;
FILE *in, *out;
long int l;

if (argc < 4)
   {
   puts("Bad arguments.");
   usage();
   exit(20);
   }

l=atol(argv[3]);

if (l <= 0)
   {
   puts("Invalid size.");
   usage();
   exit(20);
   }

if ((in = fopen (argv[1], "r")) == 0)
   {
   printf("Can't open %s\n", argv[1]);
   exit(20);
   }

if ((out = fopen (argv[2], "w")) == 0)
   {
   printf("Can't open %s\n", argv[2]);
   exit(20);
   }

printf("Writing %d bytes from %s to %s \n",l,argv[1],argv[2]);

i=0;

while (((c = getc(in)) !=EOF) && (i < l))
  {
  i=i+1;
  putc(c, out);
  }                     /*  endwhile  */

if (i == l)
   puts("Done!");
else
   puts("CHOP ended at EOF on input.");

fclose (in);
fclose (out);

}                    /* end of program  */

