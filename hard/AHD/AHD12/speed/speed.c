#include <stdio.h>
#include <dos.h>
#include <exec/memory.h>
#include <proto/dos.h>
#include <proto/exec.h>

void main()
{
long f;
char *buff, t1[8], t2[8];
long time1, time2, i, iter, size;
double ksec;

  printf("Enter block size in Kbytes->"); /* get buffer size for io */
  scanf("%ld\n", &size);
  size = size * 1024;
  printf("Enter number of iterations ->"); /* get number of iterations */
  scanf("%ld\n", &iter);                   /* to use buffer per operation */
  printf("Block size, interations = %ld, %ld\n", size, iter);
  buff = (char *)AllocMem(size, MEMF_CLEAR);
  if (buff == 0) {              /* alloc failed so exit */
    printf("Not enough contigious memory; block size = %ld\n", size);
    exit();
  }

  f = Open("test.file", MODE_NEWFILE);

  getclk(t1);  /* get system time */
  for (i = 0; i < iter; i++)
    Write(f, buff, size);
  getclk(t2);

/* the getclk call returns an char array[8], where array[5] is minutes,
   array[6] is seconds, and array[7] is hundredths of seconds */
  time1 = t1[5] * 6000 + t1[6] * 100 + t1[7];
  time2 = t2[5] * 6000 + t2[6] * 100 + t2[7];
  ksec = (double)(((double)(size * iter) / (double)(time2 - time1))
    * 100.0) / 1024.0; /* convert elapsed time to k/second */
  printf("elapsed time for write = %ld, K/sec = %10.4f\n",
     (time2 - time1), ksec);
  Close(f);

  Delay(100);  /* give file system time to settle before next test */
               /* didn't know if I needed this, but just in case */

  f = Open("test.file", MODE_OLDFILE);

  getclk(t1);
  for (i = 0; i < iter; i++)
    Read(f, buff, size);
  getclk(t2);

  time1 = t1[5] * 6000 + t1[6] * 100 + t1[7];
  time2 = t2[5] * 6000 + t2[6] * 100 + t2[7];
  ksec = (double)(((double)(size * iter) / (double)(time2 - time1))
    * 100.0) / 1024.0;  /* convert elapsed time to k/second */
  printf("elapsed time for read = %ld, K/sec = %10.4f\n",
     (time2 - time1), ksec);
  Close(f);
  DeleteFile("test.file");  /* get rid of the temp file */
  FreeMem(buff, size);
}
