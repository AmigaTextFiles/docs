/*
 *  ZKickFile <--> Commodore Kickstart file converter
 *
 *  (c)Copyright 1993 by Tobias Ferber, All Rights Reserved
 */

#include <stdio.h>

main(int argc, char *argv[])
{
  int err=0;

  if(argc < 3)
    printf("Usage:  %s ZKickFile Kickstart    (ZKickFile --> Kickstart)\n"
           "        %s Kickstart ZKickFile    (Kickstart --> ZKickFile)\n",
           argv[0],argv[0]);
  else
  { FILE *fp= fopen(argv[1],"r");
    err=20;
    if(fp)
    { long fsize;
      fseek(fp,0,2);
      fsize= ftell(fp);
      switch(fsize)
      { 
        case 512*1024+8: /* ZKickFile */
          { long *fmem= (long *)malloc(fsize);
            if(fmem)
            { long n;
              printf("loading ZKick file \"%s\" (%d bytes) to $%06lx, ",
                argv[1],fsize,fmem);
              fflush(stdout);
              fseek(fp,0,0);
              n= fread(fmem,1,fsize,fp);
              fclose(fp);
              if(n==fsize)
              { puts("ok.");
                fp= fopen(argv[2],"r");
                if(fp)
                { char c;
                  fclose(fp);
                  printf("\"%s\" already exists, overwrite? (Y/n): ",argv[2]);
                  fflush(stdout);
                  c= getchar();
                  if(c=='n' || c=='N')
                    n=0;
                }
                if(n!=0)
                { fp= fopen(argv[2],"w");
                  if(fp)
                  { printf("writing Commodore Kickstart file, ");
                    fflush(stdout);
                    n= fwrite(&fmem[2],1,fsize-8,fp);
                    fclose(fp);
                    if(n==fsize-8)
                    { puts("ok.");
                      err=0; /* don't write */
                    }
                    else puts("error.");
                  }
                  else printf("Can't write to %s\n",argv[2]);
                }
              }
              else puts("error.");
              free(fmem);
            }
            else puts("Out of memory!");
          }
          break;

        case 512*1024: /* Commodore Kickstart file */
          { long *fmem= (long *)malloc(fsize+8);
            if(fmem)
            { long n;
              printf("loading Commodore Kickstart file \"%s\" (%d bytes) to $%06lx, ",
                argv[1],fsize,fmem);
              fflush(stdout);
              fseek(fp,0,0);
              fmem[0]= 0x00000000;
              fmem[1]= 0x00080000;
              n= fread(&fmem[2],1,fsize,fp);
              fclose(fp);
              if(n==fsize)
              { puts("ok.");
                fp= fopen(argv[2],"r");
                if(fp)
                { char c;
                  fclose(fp);
                  printf("\"%s\" already exists, overwrite? (Y/n): ",argv[2]);
                  fflush(stdout);
                  c= getchar();
                  if(c=='n' || c=='N')
                    n=0;
                }
                if(n!=0)
                { fp= fopen(argv[2],"w");
                  if(fp)
                  { printf("writing ZKick file, ");
                    fflush(stdout);
                    n= fwrite(&fmem[0],1,fsize+8,fp);
                    fclose(fp);
                    if(n==fsize+8)
                    { puts("ok.");
                      err=0;
                    }
                    else puts("error.");
                  }
                  else printf("Can't write to %s\n",argv[2]);
                }
              }
              else puts("error.");
              free(fmem);
            }
            else puts("Out of memory!");
          }
          break;

        default:
          printf("Failure -- Unknown Kickstart file \"%s\"  (%d bytes)\n",
            argv[1],fsize);
          break;
      }
    }
    else printf("Can't open %s\n",argv[1]);
  }
  exit(err);
}
