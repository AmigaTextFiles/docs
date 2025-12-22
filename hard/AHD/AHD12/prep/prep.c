#include "exec/types.h"

UWORD buffer[256];

void
main()
   {
   int temp;

   puts("Cylinders");
   flushall();
   scanf("%d", &temp);
   buffer[0] = temp;

   puts("Precomp");
   flushall();
   scanf("%d", &temp);
   buffer[1] = temp;

   puts("Sectors");
   flushall();
   scanf("%d", &temp);
   buffer[2] = temp;

   puts("Heads");
   flushall();
   scanf("%d", &temp);
   buffer[3] = temp;

   puts("Interleave");
   flushall();
   scanf("%d", &temp);
   buffer[4] = temp;

   puts("Steprate");
   flushall();
   scanf("%d", &temp);
   buffer[5] = temp;

   puts("ECC Burst length");
   flushall();
   scanf("%d", &temp);
   buffer[6] = temp;

   printf("Reset...");
   flushall();
   doreset();

   printf("Format 0...");
   flushall();
   fmthard(0L);

   printf("Write...");
   flushall();
   writehardsec(buffer,0L,512L);

   printf("Reset...");
   flushall();
   doreset();

   printf("Config...");
   flushall();
   hdconfig(buffer);

   printf("Init...");
   flushall();
   doinit();

   puts("Done");
   }

