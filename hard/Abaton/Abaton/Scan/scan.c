/********************************************************************************* 
 * Abaton SCAN 300/FB (Ricoh IS30-M2) flatbed scanner controller                 *
 *-------------------------------------------------------------------------------*
 * FILE:   scan.c                                                                *
 * AUTHOR: Chris Sterne                                                          *
 * DATE:   March 3, 1999                                                         *
 *********************************************************************************/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/iffparse.h>
#include <resources/misc.h>
#include <devices/parallel.h>
#include <hardware/cia.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/misc_protos.h>
#include <clib/exec_protos.h>
#include <clib/iffparse_protos.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "packer.h"

void __regargs __chkabort(void);

void __regargs __chkabort(void)         /* Disable SAS/C Control-C checking. */
{
}

void __regargs __main(char *);          /* Replaces the SAS/C __main version. */

void __main(char *CommandLine)
{
  exit (main(CommandLine));
}

#define cmpNone     0                   /* BMHD chunk declarations. */
#define cmpByteRun1 1
#define mskNone     0

typedef UBYTE Masking;
typedef UBYTE Compression;

struct BitMapHeader                     /* BMHD chunk structure. */
{
  UWORD w, h;
  UWORD x, y;
  UBYTE nPlanes;
  Masking masking;
  Compression compression;
  UBYTE pad1;
  UWORD transparentColor;
  UBYTE xAspect, yAspect;
  WORD pageWidth, pageHeight;
};

__far extern struct CIA ciaa, ciab;

struct Library *IFFParseBase;
APTR MiscBase;

void DisplayHelp(void);
void WriteImageFile(char *, BOOL);
BOOL SendCommand(struct IOExtPar *, char *, char *);
BOOL ReceiveData(UBYTE *, ULONG);

char *VersionString   = "$VER:Scan 1.0 (3.3.1999)";
char *CommandTemplate = "SCAN,TO,QUIET/S,AREA/K,DENSITY/N/K,SENSITIVITY/N/K,INVERT/S,REFLECT/S,COMMAND/K";

/*-------------------------------------------------------------------------------*
 * FUNCTION: main                                                                *
 *-------------------------------------------------------------------------------*
 * This is the main entry point for the program.                                 *
 *-------------------------------------------------------------------------------*
 * INPUTS: CommandLine = CLI command line.                                       *
 *                                                                               *
 * OUTPUT: Always EXIT_SUCCESS.                                                  *
 *-------------------------------------------------------------------------------*/

int main(char *CommandLine)
{
  struct RDArgs *RDArguments;
  LONG Arguments[9];
  char Buffer[6];
  struct MsgPort *ParallelMP;
  struct IOExtPar *ParallelIO;
  BOOL Help, Quiet;
  
  if ((RDArguments = (struct RDArgs *)AllocDosObject(DOS_RDARGS, NULL)) != NULL)
  {
    RDArguments->RDA_Source.CS_Buffer = CommandLine;
    RDArguments->RDA_Source.CS_Length = strlen(CommandLine) + 1;
    RDArguments->RDA_Source.CS_CurChr = 0;
    RDArguments->RDA_DAList           = NULL;
    RDArguments->RDA_Buffer           = NULL;
    RDArguments->RDA_Flags            = RDAF_NOPROMPT;

    *(CommandLine + RDArguments->RDA_Source.CS_Length - 1) = '\n';

    Arguments[0] = NULL;
    Arguments[1] = NULL;
    Arguments[2] = NULL;
    Arguments[3] = NULL;
    Arguments[4] = NULL;
    Arguments[5] = NULL;
    Arguments[6] = NULL;
    Arguments[7] = NULL;
    Arguments[8] = NULL;

    if (ReadArgs(CommandTemplate, Arguments, RDArguments) != NULL)    
    {
      if ((ParallelMP = CreatePort (0,0)) != NULL)
      {
        if ((ParallelIO = (struct IOExtPar *)CreateExtIO(ParallelMP, sizeof(struct IOExtPar))) != NULL)
        {
          Quiet = FALSE;
          Help  = TRUE;
          
          if ((BOOL)Arguments[8])
          {
            /*----------------------*
             * Raw scanner command. *
             *----------------------*/
            
            SendCommand(ParallelIO, (char *)Arguments[8], NULL);
            Help = FALSE;
          }
          
          if ((BOOL)Arguments[7])
          {
            /*--------------------------*
             * Enable image reflection. *
             *--------------------------*/
            
            SendCommand(ParallelIO, "RF", "S");
            Help = FALSE;
          }
  
          if ((BOOL)Arguments[6])
          {
            /*-------------------------*
             * Enable image inversion. *
             *-------------------------*/
            
            SendCommand(ParallelIO, "IV", "S");
            Help = FALSE;
          }
                
          if (Arguments[5] != NULL)
          {
            /*----------------------------*
             * Set the sensitivity level. *
             *----------------------------*/
            
            stci_h(Buffer, *((int *)Arguments[5]));
            SendCommand(ParallelIO, "LV", Buffer);
            Help = FALSE;
          }
               
          if (Arguments[4] != NULL)
          {
            /*-----------------------------*
             * Set the scan pixel density. *
             *-----------------------------*/
            
            stci_d(Buffer, *((int *)Arguments[4]));
            SendCommand(ParallelIO, "DN", Buffer);
            Help = FALSE;
          }
  
          if (Arguments[3] != NULL)
          {
            /*--------------------*
             * Set the scan area. *
             *--------------------*/
            
            SendCommand(ParallelIO, "DA", (char *)Arguments[3]);
            Help = FALSE;
          }
          
          if ((BOOL)Arguments[2])
          {
            /*--------------------*
             * Select quiet mode. *
             *--------------------*/
            
            Quiet = TRUE;
            Help  = FALSE;
          }
          
          if (Arguments[1] != NULL)
          {
            if (stricmp((char *)Arguments[1], "?") != 0)
            {
              /*--------------------------------------------------*
               * An image file name was given.  Scan the selected *
               * area, and save the data to the file.             *
               *--------------------------------------------------*/
              
              SendCommand(ParallelIO, "RA", NULL);
              WriteImageFile((char *)Arguments[1], Quiet);
              
              /*--------------------------------------------*
               * Turn off the illumination lamp, and return *
               * the image properties to normal.            *
               *--------------------------------------------*/
              
              SendCommand(ParallelIO, "FL", "L");
              SendCommand(ParallelIO, "IV", "R");
              SendCommand(ParallelIO, "RF", "R");
              Help = FALSE;
            }
          }
          
          if (Help)
            DisplayHelp();
          
          DeleteExtIO((struct IORequest*)ParallelIO);
        }
        else
          printf("Unable to create IORequest.\n");

        DeletePort(ParallelMP);
      }
      else
        printf("Unable to create message port.\n");
      
      FreeArgs(RDArguments); 
    }
    
    FreeDosObject(DOS_RDARGS, RDArguments);
  }
        
  return EXIT_SUCCESS;
}

/*-------------------------------------------------------------------------------*
 * FUNCTION: DisplayHelp                                                         *
 *-------------------------------------------------------------------------------*
 * This function displays command arguments and purpose.                         *
 *-------------------------------------------------------------------------------*
 * INPUTS: None.                                                                 *
 *                                                                               *
 * OUTPUT: None.                                                                 *
 *-------------------------------------------------------------------------------*/

void DisplayHelp(void)
{
  printf("-------------------------------------------------------\n");
  printf(" Abaton SCAN300/FB (Ricoh IS30-M2) scanner controller\n");
  printf("    for use with a custom Parallel Port interface.\n");
  printf("-------------------------------------------------------\n");
  printf("   By Chris Sterne                       Version 1.0\n");
  printf("-------------------------------------------------------\n\n");
          
  printf("%s\n\n", CommandTemplate);
          
  printf("TO is an ILBM image file to create.\n\n");

  printf("QUIET prevents the display of information when scanning.\n\n");

  printf("DENSITY selects the scan Dots Per Inch (DPI):\n");
  printf("  300, 240, 200, or 180\n\n");
          
  printf("AREA selects the scan area:\n");
  printf("  A4             (210mm x 297mm)\n");
  printf("  A5             (210mm x 150mm)\n");
  printf("  B5             (176mm x 250mm)\n");
  printf("  B6             (176mm x 125mm)\n");
  printf("  LT             (8.5\" x 11.0\" Letter)\n");
  printf("  14             (8.5\" x 14.0\" Legal)\n");
  printf("  AT             (8.1\" x 14.0\")\n");
  printf("  CD             (3.5\" x 2.0\" Business Card)\n");
  printf("  (BX+BW,PY+PH)  Byte X offset and width, pixel Y offset and height.\n");
  printf("                 (A byte represents eight horizontal pixels)\n\n");

  printf("SENSITIVITY adjusts the response to image variations.\n");
  printf("Range is 0 to 15, with 0 being the lowest sensitivity.\n\n");

  printf("INVERT produces an inverted image.\n\n");

  printf("REFLECT produces an image reflected about the Y-axis.\n\n");

  printf("COMMAND allows sending a raw command to the scanner.\n");
  printf("An \'<ESC>!\' prefix and \'<CR>\' suffix will be added.\n\n");

  return;
}

/*-------------------------------------------------------------------------------*
 * FUNCTION: SendCommand                                                         *
 *-------------------------------------------------------------------------------*
 * This function builds a command code sequence, then sends it to the scanner.   *
 * (eg. <ESC> ! <Command> <Argument> <CR>)                                       *
 *-------------------------------------------------------------------------------*
 * INPUTS: ParallelIO = Parallel device I/O request.                             *
 *         Command    = Scanner command string.                                  *
 *         Argument   = Scanner command argument string.                         *
 *                                                                               *
 * OUTPUT: TRUE if successful, or FALSE if aborted by pressing Control-C.        *
 *-------------------------------------------------------------------------------*/

BOOL SendCommand(struct IOExtPar *ParallelIO, char *Command, char *Argument)
{
  ULONG WaitSignals, ReturnSignals;
  char *Parts[4];
  UBYTE Index;
  BOOL Success;

  if (OpenDevice(PARALLELNAME, 0, (struct IORequest *)ParallelIO, 0) == 0)
  {
    ParallelIO->IOPar.io_Command = CMD_WRITE;
    ParallelIO->IOPar.io_Flags   = 0;

    /*--------------------------------------------*
     * The scanner expects upper-case ASCII text. *
     *--------------------------------------------*/

    if (Command != NULL)
      strupr(Command);
    
    if (Argument != NULL)
      strupr(Argument);
    
    /*-----------------------------*
     * Build the command sequence. *
     *-----------------------------*/
    
    Parts[0] = "\x1B!";
    Parts[1] = Command;
    Parts[2] = Argument;
    Parts[3] = "\x0D";

    WaitSignals = 1 << ((struct IORequest *)ParallelIO)->io_Message.mn_ReplyPort->mp_SigBit | SIGBREAKF_CTRL_C;
    Success     = TRUE;
    Index       = 0;

    /*-----------------------------------------*
     * Send each part of the command sequence. *
     *-----------------------------------------*/

    do
    {
      if (Parts[Index] != NULL)
      {
        ParallelIO->IOPar.io_Data    = Parts[Index];
        ParallelIO->IOPar.io_Length  = strlen(ParallelIO->IOPar.io_Data);
  
        SendIO((struct IORequest *)ParallelIO);
        ReturnSignals = Wait(WaitSignals);
  
        if (ReturnSignals == SIGBREAKF_CTRL_C)
        {
          AbortIO((struct IORequest *)ParallelIO);
          WaitIO((struct IORequest *)ParallelIO);
          Success = FALSE;
        }
      }

      Index ++;
    }
    while ((Success) && (Index != 4));
  
    CloseDevice((struct IORequest *)ParallelIO);
  }
  else
  {
    printf("Unable to open the Parallel Device.\n");
    Success = FALSE;
  }

  return Success;
}

/*-------------------------------------------------------------------------------*
 * FUNCTION: WriteImageFile                                                      *
 *-------------------------------------------------------------------------------*
 * This function reads scan data, and writes it as an IFF compressed ILBM image  *
 * file.                                                                         *
 *-------------------------------------------------------------------------------*
 * INPUTS: FileName = Parallel device I/O request.                               *
 *         Quiet    = If TRUE, don't print scan information.                     *
 *                                                                               *
 * OUTPUT: None.                                                                 *
 *-------------------------------------------------------------------------------*/

void WriteImageFile(char *FileName, BOOL Quiet)
{
  struct IFFHandle *IFFHandle;
  struct BitMapHeader *BitMapHeader;
  ULONG ID_ILBM, ID_BMHD, ID_BODY;
  char Buffer[6];
  BYTE *ReadBuffer, *WriteBuffer;
  int Density, ByteWidth, RowWidth, PixelHeight;
  ULONG TotalSize, CompressSize;
  BOOL Success;

  if ((IFFParseBase = OpenLibrary("iffparse.library", 37)) != NULL)
  {
    if ((MiscBase = OpenResource(MISCNAME)) != NULL)
    {
      /*------------------------------------------------*
       * Acquire access to the Parallel Port resources. *
       *------------------------------------------------*/
      
      if (AllocMiscResource(MR_PARALLELPORT, "Scan") == NULL)
      {
        if (AllocMiscResource(MR_PARALLELBITS, "Scan") == NULL)
        {
          /*------------------------------------------*
           * Drive the interface READ# signal active. *
           *------------------------------------------*/

          ciab.ciapra  &= ~0x04;
          ciab.ciaddra |= 0x04;
        
          /*-------------------------------------------*
           * Read the scan information section header. *
           *-------------------------------------------*/
        
          Success = FALSE;
        
          if (ReceiveData(Buffer, 3))
          {
            /*-------------------------------*
             * Read the scan density digits. *
             *-------------------------------*/
          
            if (ReceiveData(Buffer, 3))
            {
              Buffer[3] = NULL;
              stcd_i(Buffer, &Density);
            
              /*-------------------------------------*
               * Read the scan bytes per row digits. *
               *-------------------------------------*/
          
              if (ReceiveData(Buffer, 4))
              {
                Buffer[4] = NULL;
                stcd_i(Buffer, &ByteWidth);
              
                /*----------------------------------*
                 * Read the total scan rows digits. *
                 *----------------------------------*/
          
                if (ReceiveData(Buffer, 5))
                {
                  Buffer[5] = NULL;
                  stcd_i(Buffer, &PixelHeight);
              
                  /*------------------------------------*
                   * Read the scan data section header. *
                   *------------------------------------*/
          
                  if (ReceiveData(Buffer, 3))
                  {
                    /*--------------------------------------------*
                     * If requested, print some scan information. *
                     *--------------------------------------------*/
                   
                    if (!Quiet)
                    {
                      printf("Pixels per inch: %d\n", Density);
                      printf("Pixel width:     %d\n", ByteWidth * 8);
                      printf("Pixel height:    %d\n", PixelHeight);
                    }
                        
                    if ((IFFHandle = AllocIFF()) != NULL)
                    {
                      InitIFFasDOS(IFFHandle);
                
                      if ((IFFHandle->iff_Stream = Open(FileName, MODE_NEWFILE)) != NULL)
                      {
                        OpenIFF(IFFHandle, IFFF_WRITE);

                        ID_ILBM = MAKE_ID('I', 'L', 'B', 'M');
                        ID_BMHD = MAKE_ID('B', 'M', 'H', 'D');
                        ID_BODY = MAKE_ID('B', 'O', 'D', 'Y');
                          
                        /*--------------------*
                         * Begin an IFF form. *
                         *--------------------*/
        
                        PushChunk(IFFHandle, ID_ILBM, ID_FORM, IFFSIZE_UNKNOWN);
                
                        if ((BitMapHeader = AllocVec(sizeof(struct BitMapHeader), MEMF_ANY)) != NULL)
                        {
                          BitMapHeader->w                = ByteWidth * 8;
                          BitMapHeader->h                = PixelHeight;
                          BitMapHeader->x                = 0;
                          BitMapHeader->y                = 0;
                          BitMapHeader->nPlanes          = 1;
                          BitMapHeader->masking          = mskNone;
                          BitMapHeader->compression      = cmpByteRun1;
                          BitMapHeader->transparentColor = 1;
                          BitMapHeader->xAspect          = 1;
                          BitMapHeader->yAspect          = 1;
                          BitMapHeader->pageWidth        = BitMapHeader->w;
                          BitMapHeader->pageHeight       = BitMapHeader->h;
          
                          /*-----------------------*
                           * Add an BitMap header. *
                           *-----------------------*/
                            
                          PushChunk(IFFHandle, ID_ILBM, ID_BMHD, sizeof(struct BitMapHeader));
                          WriteChunkBytes(IFFHandle, BitMapHeader, sizeof(struct BitMapHeader));
                          PopChunk(IFFHandle);
                          
                          /*-----------------*
                           * Add image data. *
                           *-----------------*/
                                
                          PushChunk(IFFHandle, ID_ILBM, ID_BODY, IFFSIZE_UNKNOWN);
                          
                          TotalSize = ByteWidth * PixelHeight;
                          
                          /*------------------------------------------------------*
                           * Ensure an even number of bytes per raster scan-line. *
                           *------------------------------------------------------*/
                          
                          if (ByteWidth & 0x01)
                            RowWidth = ByteWidth + 1;
                          else
                            RowWidth = ByteWidth;
                          
                          ReadBuffer  = AllocVec(RowWidth, MEMF_ANY);
                          WriteBuffer = AllocVec(MaxPackedSize(RowWidth), MEMF_ANY);
                          
                          if ((ReadBuffer != NULL) && (WriteBuffer != NULL))
                          {
                            do
                            {
                              if (ReceiveData(ReadBuffer, ByteWidth))
                              {
                                CompressSize = PackRow(ReadBuffer, WriteBuffer, RowWidth);
                                WriteChunkBytes(IFFHandle, WriteBuffer, CompressSize);
                                TotalSize -= ByteWidth;
                              }
                              else
                                TotalSize = 0;
                            }
                            while (TotalSize != 0);
                          }
                          
                          PopChunk(IFFHandle);
                          FreeVec(ReadBuffer);
                          FreeVec(WriteBuffer);
                          
                          /*-------------------------------------*
                           * Read the scan termination sequence. *
                           *-------------------------------------*/
          
                          if (Success = ReceiveData(Buffer, 4))
                          {
                            if (!Quiet)
                              printf("Scan complete.\n");
                          }
                        }
                          
                        /*-------------------*
                         * End the IFF form. *
                         *-------------------*/
                            
                        PopChunk(IFFHandle);
                        CloseIFF(IFFHandle);
                        Close(IFFHandle->iff_Stream);
                      }
                      else
                        printf("Unable to open file: %s\n", FileName);
                      
                      FreeIFF(IFFHandle);
                    }
                  }
                }
              }
            }
          }

          /*--------------------------------------------*
           * Float the interface READ# signal inactive. *
           *--------------------------------------------*/
        
          ciab.ciapra  |= 0x04;
          ciab.ciaddra &= ~0x04;

          FreeMiscResource(MR_PARALLELBITS);    
        }
        else
          printf("Parallel Port resources are currently owned.\n");
      
        FreeMiscResource(MR_PARALLELPORT);
      }
      else
        printf("Parallel Port resources are currently owned.\n");
    }
    
    CloseLibrary(IFFParseBase);
  }
  else
    printf("Unable to open 'iffparse.library' V37).\n");

  return;
}

/*-------------------------------------------------------------------------------*
 * FUNCTION: ReceiveData                                                         *
 *-------------------------------------------------------------------------------*
 * This function reads data from the scanner.  The interface READ# signal must   *
 * asserted before calling this function, including the sending of a command     *
 * that will actually return data.                                               *
 *-------------------------------------------------------------------------------*
 * INPUTS: Buffer = Buffer to save data.                                         *
 *         Size   = Buffer size.                                                 *
 *                                                                               *
 * OUTPUT: TRUE if successful, or FALSE if aborted by pressing of CTRL_C.        *
 *-------------------------------------------------------------------------------*/

BOOL ReceiveData(UBYTE *Buffer, ULONG Size)
{
  ULONG DataCounter, TrialCounter;
  UBYTE Dummy;
  BOOL Success;
  
  Success     = TRUE;
  DataCounter = 0;
        
  do
  {
    TrialCounter = 100;
            
    do
    {
      /*----------------------------------------------------*
       * Wait for the interface BUSY signal to be asserted, *
       * indicating the availability of data.               *
       *----------------------------------------------------*/
      
      if ((ciab.ciapra & 0x01) == 0x01)
      {
        /*----------------------------------------------------*
         * Read the latched data from the scanner.  This will *
         * trigger the generation of a STROBE# pulse.         *
         *----------------------------------------------------*/
        
        Buffer[DataCounter] = ciaa.ciaprb;
        
        /*---------------------------------------------------*
         * A dummy read of the status register provides time *
         * for the CIA chip to generate a STROBE# to clear   *
         * the BUSY driver latch, before the BUSY status is  *
         * polled again.                                     *
         *---------------------------------------------------*/
        
        Dummy = ciab.ciapra;
        DataCounter ++;
      }

      TrialCounter --;
    }
    while ((TrialCounter != 0) && (DataCounter != Size));
  
    /*----------------------------*
     * Check for a Break request. *
     *----------------------------*/
  
    if (SetSignal(0,0) & SIGBREAKF_CTRL_C)
    {
      DataCounter = Size;
      Success     = FALSE;
    }
  }
  while (DataCounter != Size);
  
  return Success;
}
