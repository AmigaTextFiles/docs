int fmthard(unsigned long);
int readhardsec(char *, long, long);

unsigned short buf[256];

void
main()
   {
   int start, end, temp;

   doreset();
   if(readhardsec((char *)buf, 0L, 512L)) exit();

   puts("Start format at track");
   flushall();
   scanf("%d", &start);

   puts("End format at track");
   flushall();
   scanf("%d", &end);

   for(temp = start ; temp <= end ; temp++)
      {
      printf("Track :%d\r", temp);
      fmthard(temp * 512L * buf[2] * buf[3]);
      }
   puts("");
   }

