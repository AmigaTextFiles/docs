typedef unsigned long ULONG;

int readhardsec(void *, ULONG, ULONG);

short buf[256];

void
main()
   {
   long i;

   i = 0;
   readhardsec(buf, 0L, 512L);
   buf[2] = 30;
   hdconfig(buf);

   while(readhardsec(buf, i<<9, 512L) == 0)
      {
      printf("Read %d ok\r", i);
      i++;
      if(i > 64) break;
      }
   printf("\nUse %d as track#\n", i);
   }

