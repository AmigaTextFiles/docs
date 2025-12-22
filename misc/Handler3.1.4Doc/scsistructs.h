/*
** This file defines multiple SCSI structs that are not available
** otherwise. The source of these structures is the SCSI-2
** specification.
*/

#ifndef SCSISTRUCTS_H
#define SCSISTRUCTS_H

#include <exec/types.h>

/*
** A SCSI 10-byte command
*/
struct SCSI10Cmd {
  UBYTE  scsi10_Cmd;   /* a SCSI command */
  UBYTE  scsi10_Lun;   /* the LUN of the device */
  ULONG  scsi10_Block; /* logical block offset */
  UBYTE  scsi10_reserved;
  UBYTE  scsi10_BlockCntHi; /* higher 8 bits. Not in one field as it is not aligned */
  UBYTE  scsi10_BlockCntLo; /* lower 8 bits of the block count */
  UBYTE  scsi10_Control;
};

/*
** A SCSI 6-byte command
*/
struct SCSI6Cmd {
  UBYTE  scsi6_Cmd;
  UBYTE  scsi6_Lun;      /* LUN, and logical block */
  UWORD  scsi6_Block;    /* logical block */
  UBYTE  scsi6_BlockCnt; /* logical size */
  UBYTE  scsi6_Control;  /* control */
};

/*
** SCSIInquiry result structure
*/
struct SCSIInquiry {
  UBYTE	  sci_Status;
  UBYTE   sci_Modification;
  UBYTE   sci_Version;
  UBYTE   sci_Format;
  UBYTE   sci_AdditionalBytes;
  UBYTE   sci_reserved[2];
  UBYTE   sci_Flags;
  UBYTE   sci_Provider[8];
  UBYTE	  sci_Product[16];
  UBYTE   sci_ProdVersion[4];
  UBYTE   sci_Date[8];
  UBYTE   sci_Comment[12];
};

/*
** The capacity information
*/
struct SCSICapacity {
  ULONG	scc_Block;
  ULONG scc_BlockLength;
};


/*
** A generic SCSI page
*/
struct SCSIPage {
  UBYTE                   scp_PageCode;
  UBYTE                   scp_PageLength;
};


/*
** Rigid disk page
*/
struct RigidDiskPage {
  UBYTE	rgp_NumberOfCylinders[3];
  UBYTE	rgp_NumberOfHeads;
  UBYTE	rgp_StartPrecomp[3];
  UBYTE	rgp_StartReducedWrite[3];
  UWORD	rgp_StepRate;
  UBYTE rgp_LandingZone[3];
  UBYTE	rgp_RPL;
  UBYTE	rgp_RotationalOffset;
  UBYTE	rgp_reserved;
  UWORD	rgp_RotationRate;
};

/*
** SCSIPageHeader
*/
struct SCSIPageHeader {
  UBYTE	spch_ModeDataLength;
  UBYTE	spch_MediumType;
  UBYTE	spch_DeviceSpecific;
  UBYTE	spch_BlockDescriptorLength;
};

/*
** SCSI block descriptor
*/
struct SCSIBlockDescriptor {
  ULONG	scbd_NumberOfBlocks; /* bits 31 to 24 are used for the density code */
  ULONG	scbd_BlockLength;    /* bits 31 to 24 are reserved */
};

/* 
** SCSIModeSense
*/
struct SCSIModeSense {
  UBYTE buffer[254];
};

/*
** SCSI commands needed
*/

#define SCSI_TEST_UNIT_READY 0x00
#define SCSI_READ10  0x28
#define SCSI_WRITE10 0x2a
#define SCSI_INQUIRY 0x12
#define SCSI_MODE_SENSE 0x1a
#define SCSI_READ_CAPACITY 0x25

/*
** SCSI status codes
*/
#define SSTS_GOOD 0x00
#define SSTS_INTERMEDIATE 0x10

/*
** SCSI extended sense buffer for autosense
*/
struct SCSIExtendedSense {
  UBYTE 	exs_ErrorCode;
  UBYTE   	exs_SegmentID;
  UBYTE   	exs_SenseFlags;
  UBYTE         exs_LBA[4]; /* logical block address */
  UBYTE   	exs_SenseLength;
  UBYTE  	exs_CmdInfo[4];
  UBYTE   	exs_ASC;
  UBYTE   	exs_ASCQ; /* Error codes. */
  UBYTE   	exs_FRUC;
  UBYTE   	exs_Bits;
  UBYTE  	exs_BytePos[2];
  UWORD   	exs_Cylinder;
  UBYTE   	exs_Head;
  UBYTE   	exs_Sector;
};

#endif
