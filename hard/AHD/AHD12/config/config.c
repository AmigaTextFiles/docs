typedef unsigned long ULONG;
typedef unsigned short USHORT;

int readhardsec(char *, ULONG, ULONG);

USHORT buf[256];

void
main()
   {
   if(readhardsec((char *)buf, 0L, 512L) == 0)
      {
      printf("Cylinders:        %d\n",buf[0]);
      printf("Precomp:          %d\n",buf[1]);
      printf("Sectors:          %d\n",buf[2]);
      printf("Heads:            %d\n",buf[3]);
      printf("Interleave:       %d\n", buf[4]);
      printf("Steprate:         %d\n", buf[5]);
      printf("ECC Burst length: %d\n", buf[6]);
      }
   }

