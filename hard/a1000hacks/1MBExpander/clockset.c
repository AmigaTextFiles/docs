static int adr[6]={9,8,7,4,2,0};
static char *month[12]={
       "Jan",
       "Feb",
       "Mar",
       "Apr",
       "May",
       "Jun",
       "Jul",
       "Aug",
       "Sep",
       "Oct",
       "Nov",
       "Dec"};

static unsigned char d,i,*adradr=(char *)0x600003,*dataadr=(char *)0x600001;

readclock(data)
char data[];
{
    *adradr=0xc;/* check for end of update cycle */
    d=*dataadr;
    do {
        *adradr=0xc;
    } while((*dataadr&0x10)==0);
    /* here if just completed update cycle */
    do {
        for(i=0;i<6;i++) {
           *adradr=adr[i];
           data[i]=*dataadr;
        }
        *adradr=0xa;
        if((*dataadr&0x80)!=0) continue;/* update */
        *adradr=0xc;
    } while((*dataadr&0x10)!=0);
    /* here if read without encountering another update */
}

writeclock(data)
char data[];
{
    *adradr=0xc;/* check for end of update cycle */
    d=*dataadr;
    do {
        *adradr=0xc;
    } while((*dataadr&0x10)==0);
    /* here if just completed update cycle */
    do {
        for(i=0;i<6;i++) {
           *adradr=adr[i];
           *dataadr=data[i];
        }
        *adradr=0xa;
        if((*dataadr&0x80)!=0) continue;/* update */
        *adradr=0xc;
    } while((*dataadr&0x10)!=0);
    /* here if written without encountering another update */
}

main(argc,argv)
int argc;
char *argv[];
{
    int i;
    char data[6];
    char string[40];
    int day,year,hour,min,sec;
    /* check validity of clock */
    *adradr=0xa;
    if((i=(*dataadr&0x7f))!=0x20)
    {
        printf("reg a is %d\n",i);
        *adradr=0xa;
        *dataadr=0x20;
        *adradr=0xd;
        *dataadr=0;
    }
    *adradr=0xb;
    if((i=*dataadr)!=0x7)
    {
        printf("reg b is %d\n",i);
        *adradr=0xb;
        *dataadr=0x7;
        *adradr=0xd;
        *dataadr=0;
    }
    *adradr=0xd;
    if(((i=*dataadr) != 0x80) && (argc < 3))
    {
        printf("reg d is %d\n",i);
        printf("CLOCK CHIP INVALID\n");
        printf("To validate clock chip execute:\n");
        printf("  clock dd-mmm-yy hh:mm:ss\n");
        exit(30);
    }
    *adradr=0xd;
    *dataadr=0x80; /* set clock ok bit */
    readclock(data);
    while((argc--)>1){
       if(strlen(argv[argc])==9&&argv[argc][2]=='-'&&argv[argc][6]=='-')
       {  /* handle date */
          sscanf(argv[argc],"%2d-%3s-%2d",&day,string,&year);
          if(day>0&&day<32) data[2]=day;
          else {
              printf("bad day of month\n");
              exit(30);
          }
          for(i=0;i<12;i++) {
              for(d=0;d<3;d++) {
                 if(tolower(string[d])!=tolower(month[i][d])) break;
                 else if(d==2) data[1]=i+1;
              }
              if(d==3) break;
          }
          if(i==12){
              printf("bad month\n");
              exit(30);
          }
          data[0]=year;
       }
       else if(strlen(argv[argc])>4&&argv[argc][2]==':') /* time */
       {  /* handle time */
          if(strlen(argv[argc])==8&&argv[argc][5]==':')
             sscanf(argv[argc],"%2d:%2d:%2d",&hour,&min,&sec);
          else {
             sscanf(argv[argc],"%2d:%2d",&hour,&min);
             sec=0;
          }
          if(hour>=0&&hour<24) data[3]=hour;
          else {
              printf("bad hour\n");
              exit(30);
          }
          if(min>=0 && min<60) data[4]=min;
          else {
              printf("bad minute\n");
              exit(30);
          }
          if(sec>=0 && sec<60) data[5]=sec;
          else {
              printf("bad second\n");
              exit(30);
          }
       }
       else /* syntax error */
       {
           printf("Incorrect arguements\n");
           exit(30);
       }
       writeclock(data);
    }
    
    sprintf(string,"date %2d-%3s-%2d %2d:%2d:%2d\n",data[2],month[data[1]-1],
       data[0],data[3],data[4],data[5]);
    for(i=0;string[i];i++) {
       if(string[i]==' ' && i!=4 && i!=14) string[i]='0';
    }
    if((!Execute(string,0,0))||(!Execute("date\n",0,0)))
       printf("\nDATE INVALID\n");
}


