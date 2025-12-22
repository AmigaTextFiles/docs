main(argc,argv)
    long argc;
    char *argv[];
{
    unsigned short *adr;
    int i,j,k,n;
    adr=0x0400000;
    for(i=0;i<0x010000;i++)
    {
        for(j=0x000000;j<0x080000;j++)
        {
            adr[j]=j+i+j>>12;
        }
        for(j=0x000000;j<0x080000;j++)
        {
           k=adr[j];
           n=(j+i+j>>12)&0x0ffff;
           if((n!=k)&&(argc>1))
         printf("wrote %4x read %4x diff %4x at addr %6x\n",n,k,n^k,&adr[j]);
        }
    }
}



