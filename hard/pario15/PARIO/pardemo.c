/*
   pardemo.c
   Parallel Port Input/Output Demo
   v1.5
   Tom Handley
   15 Apr 93
   Compiled with Manx v5.20a. To compile and link:
      cc pardemo.c
      ln pario.o pardemo.o -lc
*/

#include    "pardemo.h"

/* 
   Quit()
   Free parallel port and quit program
   Entry : char whytext[]   = Exit text
           LONG return_code = Error code
   Exit  : return_code = 0 if success, error code if unable to access port
*/

void Quit(char whytext[], LONG return_code)
{
   if(return_code == 0)              /* Assembly routine to de-allocate */
      freeport();                    /*    parallel port */
   printf("%s\n",whytext);           /* Display exit text */
   exit(return_code);                /* Exit with error code */
}

/*
   GetMenu()
   Get menu selection
   Return: int choice = Menu selection
*/

int GetMenu(void)
{
   UBYTE error = FALSE;  /* Error flag */
   int   choice;         /* Menu selection */

   do
   {  /* Get menu selection */
      CXY(CHOICEX,CHOICEY);     /* Prompt for selection */
      EOL;
      scanf("%d", &choice);

      /* Check for valid selection */
      if(choice < MENUMIN || choice >MENUMAX)
         error = TRUE;
      else
         error = FALSE;
   }  while(error);

   CXY(CHOICEX,CHOICEY);        /* Erase prompt */
   EOL;
   return(choice);              /* Return menu selection */
}

/*
   GetData()
   Get data input for write port operation
   Entry : int   choice = Menu selection
   Return: UBYTE data   = Data to write to port
*/

UBYTE GetData(int choice)
{
   UBYTE error = FALSE;  /* Error flag */
   UBYTE data;           /* Data returned */
   int   din;            /* Data input */

   do
   {  CXY(PROMPTX,PROMPTY);         /* Prompt for input */
      EOL;
      printf("%s", prompt[choice]);

      /* Get data */
      if(datatype == STATE)         /* Determine data type (state or hex) */
         scanf("%d", &din);
      else
         scanf("%x", &din);

      /* Check for valid data */
      if((datatype == STATE) && (din < 0 || din > 1))
         error = TRUE;
      else if((datatype == HEX) && (din < 0x00 || din > 0xFF))
         error = TRUE;
      else
         error = FALSE;
   }  while(error);

   CXY(PROMPTX,PROMPTY);            /* Erase Prompt */
   EOL;
   data = din;
   currentdata[choice] = data;      /* Update current data */
   if(choice == 1)
   {  if(data == 0)                 /* If changing port direction, update */
         currentdata[2] = 0x00;     /* port direction bits data (choice #2) */
      else
         currentdata[2] = 0xFF;
   }
   return(data);                    /* Return data */
}

/*
   DisplayData()
   Display port I/O data
   Entry : int   choice = Menu selection
           UBYTE data   = Port data to display
*/

void DisplayData(int choice, UBYTE data)
{
   CXY(DATAX,choice+DATAY);        /* Move cursor to data item */
   EOL;

   if(datatype == STATE)           /* Determine data type (state or hex) */
      printf("%s", statelabel[statetype][data]);
   else
      printf("$%.2X", data);

   /* When changing data direction, erase/update related data items */
   switch(choice)
   {  case  1:
             CXY(DATAX,DATAY+2);   /* Erase port direction bits data item */
             EOL;
             if(data == 0)         /* Update port direction bits data item */
                printf("$%.2X", 0x00);
             else
                printf("$%.2X", 0xFF);
             CXY(DATAX,DATAY+3);   /* Erase read/write port data items */
             EOL;
             CXY(DATAX,DATAY+4);
             EOL;
             break;
      case  2:
             CXY(DATAX,DATAY+1);   /* Erase port direction data item */
             EOL;
             CXY(DATAX,DATAY+3);   /* Erase read/write port data items */
             EOL;
             CXY(DATAX,DATAY+4);
             EOL;
             break;
      case  5:
             CXY(DATAX,DATAY+6);   /* Erase BUSY read/set data items */
             EOL;
             CXY(DATAX,DATAY+7);
             EOL;
             break;
      case  8:
             CXY(DATAX,DATAY+9);   /* Erase POUT read/set data items */
             EOL;
             CXY(DATAX,DATAY+10);
             EOL;
             break;
      case 11:
             CXY(DATAX,DATAY+12);  /* Erase SEL read/set data items */
             EOL;
             CXY(DATAX,DATAY+13);
             EOL;
             break;
   }
}

/* Main program */

void main(void)
{
   UBYTE data;            /* Port I/O data */
   LONG  error = 0;       /* Error code on exit */
   int   choice;          /* Menu selection */

   #ifdef  AZTEC_C
   Enable_Abort = 0;      /* Turn off MANX CTRL-C abort handling */
   #endif

   /* getport() is an assembly routine that tires to allocate the parallel port
      and initially sets the port, BUSY, POUT, and SEL lines to inputs.
   */

   if(error = getport())
      Quit("Parallel port in use", error);

   CLS;                      /* Display menu */
   CXY(MENUX,MENUY);
   puts(menutxt);

   /* Main event loop */

   while(TRUE)
   {  choice = GetMenu();    /* Get menu selection */
      if(choice == 0)        /* Quit? */
         break;

      switch(choice)
      {   case  1:                         /* Set port data direction */
                 datatype = STATE;
                 statetype = DIRECTION;
                 data = GetData(choice);
                 portdir(data);
                 DisplayData(choice, data);
                 break;
          case  2:                         /* Set port data direction bits */
                 datatype = HEX;
                 data = GetData(choice);
                 portddr(data);
                 DisplayData(choice, data);
                 break;
          case  3:                         /* Read data port */
                 datatype = HEX;
                 data = rdport();
                 DisplayData(choice, data);
                 break;
          case  4:                         /* Write data port */
                 if(currentdata[2] != 0)
                 {  datatype = HEX;        /* Only write if at least one bit */
                    data = GetData(choice);   /* dir set to output */
                    wrport(data);
                    DisplayData(choice, data);
                 }
                 break;
          case  5:                         /* Set BUSY Direction Bit */
                 datatype = STATE;
                 statetype = DIRECTION;
                 data = GetData(choice);
                 busydir(data);
                 DisplayData(choice, data);
                 break;
          case  6:                         /* Read BUSY state */
                 datatype = STATE;
                 statetype = LEVEL;
                 data = rdbusy();
                 DisplayData(choice, data);
                 break;
          case  7:                         /* Set BUSY state */
                 if(currentdata[5] == 1)
                 {  datatype = STATE;      /* Only write if dir set to output */
                    statetype = LEVEL;
                    data = GetData(choice);
                    setbusy(data);
                    DisplayData(choice, data);
                 }
                 break;
          case  8:                         /* Set POUT Direction Bit */
                 datatype = STATE;
                 statetype = DIRECTION;
                 data = GetData(choice);
                 poutdir(data);
                 DisplayData(choice, data);
                 break;
          case  9:                         /* Read POUT state */
                 datatype = STATE;
                 statetype = LEVEL;
                 data = rdpout();
                 DisplayData(choice, data);
                 break;
          case 10:                         /* Set POUT state */
                 if(currentdata[8] == 1)
                 {  datatype = STATE;      /* Only write if dir set to output */
                    statetype = LEVEL;
                    data = GetData(choice);
                    setpout(data);
                    DisplayData(choice, data);
                 }
                 break;
          case 11:                         /* Set SEL Direction Bit */
                 datatype = STATE;
                 statetype = DIRECTION;
                 data = GetData(choice);
                 seldir(data);
                 DisplayData(choice, data);
                 break;
          case 12:                         /* Read SEL state */
                 datatype = STATE;
                 statetype = LEVEL;
                 data = rdsel();
                 DisplayData(choice, data);
                 break;
          case 13:                         /* Set SEL state */
                 if(currentdata[11] == 1)
                 {  datatype = STATE;      /* Only write if dir set to output */
                    statetype = LEVEL;
                    data = GetData(choice);
                    setsel(data);
                    DisplayData(choice, data);
                 }
                 break;
      }
   }

   CXY(1,19);
   EOL;
   Quit("Normal Exit", error);
}

